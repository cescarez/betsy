class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end
  def new
    @order = Order.new
  end
  def create
    @order = Order.new(order_params)

    if @order.save
      render file: "#{Rails.root}/public/not_found.html", status: :not_found
    end

  end
  def show

  end
  def edit

  end
  def update

  end
  def destroy

  end
  private
  def order_params
    return require(:order).permit(:user_id, :order_item_id, :shipping_info_id, :billing_info_id, :completed)
  end
end
