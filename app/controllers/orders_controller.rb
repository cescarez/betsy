class OrdersController < ApplicationController
  before_action :find_order, except: [:index, :create, :status_filter]
  before_action :require_login, only: [:index]

  def index
    if @orders.nil?
      current_user = User.find_by(id: session[:user_id])
      @orders = Order.all.filter { |order| order.user == current_user }
    end
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      flash[:success] = "First item added to cart. Welcome to Stellar."
      session[:order_id] = @order.id
      redirect_to order_path(@order.id)
    else
      flash.now[:error] = "Error: shopping cart was not created."
      @order.errors.each { |name, message| flash.now[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash.now[:error] << "Please try again."
      render :new, status: :bad_request
    end
    return
  end

  def show
  end

  # def edit
  # end

  def update
    if @order.complete_date
      flash[:error] = "Your order has already been submitted for fulfillment. Please contact customer service for assistance."
      redirect_back fallback_location: order_path(@order.id)
    end

    if @order.update(order_params)
      flash[:success] = "#{@order.complete_date ? "Order" : "Shopping cart" } successfully updated."
      redirect_to order_path(@order.id)
    else
      flash.now[:error] = "Error: #{@order.complete_date ? "order" : "shopping cart" } did not update."
      @order.errors.each { |name, message| flash.now[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash.now[:error] << "Please try again."
      render :edit, status: :bad_request
    end
    return
  end

  def destroy
    if @order.destroy
      flash[:success] = "#{@order.complete_date ? "Order successfully deleted" : "Shopping cart successfully cancelled" }."
      redirect_back fallback_location: orders_path
    else
      flash[:error] = "Error: #{@order.complete_date ? "order was not deleted" : "shopping cart was not cancelled" }. Please try again."
      redirect_back fallback_location: order_path(@order.id), status: :internal_server_error
    end
    return
  end

  def complete
    if @order.update(status: "complete", complete_date: Time.now)
      flash[:success] = "Your order has successfully been submitted."
      redirect_back fallback_location: root_path
    else
      flash[:error] = "Error: Order was not completed. Please try again."
      redirect_back fallback_location: order_path(@order.id), status: :bad_request
    end
    return
  end

  def cancel
    if @order.update(status: "cancelled")
      flash[:success] = "Order ##{@order.id} successfully cancelled."
    else
      flash[:error] = "Error. Order ##{@order.id} was not cancelled. Please try again."
    end
    redirect_back fallback_location: order_path(@order.id)
    return
  end

  def status_filter
    status = params[:status]
    @orders = Order.filter_orders(status)
    render :index
    return
  end

  ###TODO: so much testing -- does this do what I think it does???
  def submit
    if session[:user_id].nil?
      flash.now[:notice] = "Please note, you are completing this order as a guest user. Please log in if you would like to associate this purchase with your account."
    end

    @order.update(submit_date: Time.now)
    @order.update(status: "paid") if @order.billing_info
    @order.order_items.each do |order_item|
      order_item.product.inventory -= order_item.quantity
    end
    flash[:success] = "Thank you for shopping with Stellar!"

    session[:order_id] = nil
    redirect_to root_path
    return
  end

  private

  def order_params
    return require(:order).permit(:user_id, :order_item_id, :shipping_info_id, :billing_info_id, :status, :submit_date, :complete_date)
  end

  def find_order
    @order = session[:order_id]

    if @order.nil?
      flash.now[:error] = "There was a problem with your cart. Please clear your cookies or close your browser and revisit Stellar."
      redirect_to root_path
      return
    end
  end
end
