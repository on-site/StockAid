module Reports
  module TotalInventoryValue
    def self.new(params, _session)
      if params[:category_id].present?
        Reports::TotalInventoryValue::SingleCategory.new(params)
      else
        Reports::TotalInventoryValue::AllCategories.new(params)
      end
    end

    module Common
      def date
        return if @params[:date].blank?
        Time.strptime(@params[:date], "%m/%d/%Y").end_of_day
      end
    end

    class SingleCategory
      include Common
      attr_accessor :category, :total_value

      def initialize(params)
        @category = Category.find(params[:category_id])
        @params = params
        @total_value = 0.0
      end

      def each
        category.items.order(:description).each do |item|
          @total_value += (item_total_value = item.total_value(at: date))
          yield category.description, item.description, item.total_count(at: date), item_total_value, "FIXME"
        end
      end
    end

    class AllCategories
      include Common
      attr_accessor :categories, :total_value

      def initialize(params)
        @categories = Category.all
        @params = params
        @total_value = 0.0
      end

      def each
        categories.each do |category|
          @total_value += (category_total_value = category.total_value(at: date))
          yield category.description, nil, category.total_count(at: date), category_total_value, "FIXME"
        end
      end
    end
  end
end
