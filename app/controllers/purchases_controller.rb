class PurchasesController < ApplicationController
  require_permission :can_view_purchases?, except: [:next_po_number]
  require_permission :can_create_purchases?, only: [:new, :create]
  require_permission :can_update_purchases?, only: [:edit, :update]

  before_action :authenticate_user!

  active_tab "purchases"

  def index
    @purchases = Purchase.includes(:vendor).where(status: PurchaseStatus::OPEN_STATUSES).order(id: :desc)
  end

  def closed
    @purchases = Purchase.includes(:vendor).closed.order(id: :desc)
  end

  def canceled
    @purchases = Purchase.includes(:vendor).canceled.order(id: :desc)
  end

  def new
    @purchase = Purchase.new(status: :new_purchase)
    @vendors = Vendor.all.order(name: :asc)

    render "purchases/status/select_items"
  end

  def create
    purchase = Purchase.create!(create_params)
    redirect_after_save "saved", purchase
  end

  def edit
    # redirect_to purchases_path unless current_user.can_view_purchases?
    @purchase = Purchase.includes(:vendor, :user, purchase_details: { item: :category }).find(params[:id])
    @vendors = Vendor.all.order(name: :asc)
    render "purchases/status/select_items"
  end

  def update
    purchase = Purchase.find(params[:id])
    purchase.update!(purchase_params)
    redirect_after_save "updated", purchase
  end

  private

  def create_params
    @create_params ||= purchase_params.to_h
    @create_params[:user_id] = current_user.id unless @create_params[:user_id].present?
    @create_params
  end

  def purchase_params
    @purchase_params ||= params.require(:purchase).permit(
      :purchase_date, :vendor_id, :vendor_po_number, :date, :tax, :shipping_cost, :status,
      purchase_details_attributes: [:id, :item_id, :quantity, :cost, :_destroy,
        purchase_shipments_attributes: [:id, :purchase_detail_id, :tracking_number, :received_date, :quantity_received, :_destroy]
      ]
    )
  end

  def redirect_after_save(action, purchase)
    if params[:save] == "save-and-close" || purchase_params[:status] == "canceled"
      redirect_to purchases_path, flash: { success: "Purchase #{action}!" }
    else
      redirect_to edit_purchase_path(purchase), flash: { success: "Purchase #{action}!" }
    end
  end
end