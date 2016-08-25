class OrdersController < ApplicationController
  active_tab "orders"

  def index
  end

  def new
    @order = Order.new status: :select_items
    render "orders/status/select_items"
  end

  def create
    order = current_user.create_order(params)
    redirect_to edit_order_path(order)
  end

  def edit
    @order = Order.find(params[:id])

    if can_edit_order?(@order)
      if Rails.root.join("app/views/orders/status/#{@order.status}.html.erb").exist?
        render "orders/status/#{@order.status}"
      end
    else
      redirect_to orders_path
    end
  end

  def update
    order = current_user.update_order params
    redirect_to edit_order_path(order)
  end
end
