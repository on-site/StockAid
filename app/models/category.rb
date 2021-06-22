class Category < ApplicationRecord
  has_many :items
  validates :description, presence: true

  default_scope { order("upper(description)") }

  def to_json
    {
      id: id,
      description: description,
      items: items.sort_by(&:description).map(&:to_json)
    }
  end

  def total_value(at: nil, unscoped: true)
    if at.blank?
      items.sum("current_quantity * value")
    else
      items_to_value = unscoped ? items.unscope(where: :deleted_at) : items
      items_to_value.includes(:versions).inject(0.0) do |sum, item|
        total = item.total_value(at: at)
        if total.present?
          sum + total
        else
          sum
        end
      end
    end
  end

  def total_count(at: nil)
    if at.blank?
      items.sum(:current_quantity)
    else
      items.includes(:versions).inject(0) do |sum, item|
        total = item.total_count(at: at)
        if total.present?
          sum + total
        else
          sum
        end
      end
    end
  end

  def self.to_json
    order(:description).with_programs_and_inject_requested_quantities.map(&:to_json).to_json
  end

  def self.with_programs_and_inject_requested_quantities
    preload(items: :programs).all.tap do |results|
      Item.inject_requested_quantities(results.map(&:items).flatten)
    end
  end

  def increment_next_sku
    next_sku.tap do
      self.next_sku += 1
      save!
    end
  end
end
