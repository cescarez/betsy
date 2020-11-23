class OrdersController < ApplicationController
  before_action :find_order, except: [:index, :create, :status_filter]
  before_action :find_order_item, only: [:show, :complete, :cancel]
  before_action :require_login, only: [:index, :complete, :cancel]

  def index
    if @orders.nil?
      current_user = User.find_by(id: session[:user_id])
      @orders = Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == current_user }}
    end
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      flash[:success] = "First item added to cart. Welcome to Stellar."
      session[:order_id] = @order.id
      # redirect_back fallback_location: order_path(@order.id)
    else
      flash[:error] = "Error: shopping cart was not created."
      @order.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      redirect_back fallback_location: root_path, status: :bad_request
    end
    return
  end

  def show
  end

  def summary
  end

  def update
    if @order.complete_date
      flash[:error] = "Your order has already been shipped. No changes may be made at this point."
      redirect_back fallback_location: order_path(@order.id)
    else
      if @order.update(order_params)
        flash[:success] = "Order successfully updated."
        redirect_back fallback_location: order_path(@order.id)
      else
        flash.now[:error] = "Error: order did not update."
        @order.errors.each { |name, message| flash.now[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
        flash.now[:error] << "Please try again."
        render :show, status: :bad_request
      end
    end

    return
  end

  # NOT CURRENTLY IMPLEMENTED ANYWHERE. WE DON'T WANT A SELLER TO DELETE A WHOLE ORDER SO THIS SEEMS LIKE AN ADMIN ACTION
  # def destroy
  #   if @order.destroy
  #     flash[:success] = "#{@order.complete_date ? "Order successfully deleted" : "Shopping cart successfully cancelled" }."
  #     redirect_back fallback_location: orders_path
  #   else
  #     flash[:error] = "Error: #{@order.complete_date ? "order was not deleted" : "shopping cart was not cancelled" }. Please try again."
  #     redirect_back fallback_location: order_path(@order.id), status: :internal_server_error
  #   end
  #   return
  # end

  def complete
    if @order_item.update(status: "complete") && @order.update(complete_date: Time.now)
      @order.validate_status
      flash[:success] = "#{@order_item.product.name.capitalize} in Order ##{@order.id} has mark and shipped and designated as 'complete'."
      redirect_back fallback_location: root_path
    else
      flash[:error] = "Error: #{@order_item.product.name.capitalize} in Order ##{@order.id} was not marked as shipped. Please try again."
      redirect_back fallback_location: order_path(@order.id), status: :bad_request
    end
    return
  end

  def cancel
    if @order_item.update(status: "cancelled")
      @order.validate_status
      flash[:success] = "#{@order_item.product.name.capitalize} in Order ##{@order.id} successfully cancelled."
    else
      flash[:error] = "Error. #{@order_item.product.name.capitalize} in Order ##{@order.id} was not cancelled. Please try again."
    end
    redirect_back fallback_location: order_path(@order.id)
    return
  end

  def status_filter
    status = params[:order][:status]
    @orders = Order.filter_orders(status)
    render :index, status: :ok
    return
  end

  def submit
    if session[:user_id].nil?
      flash.now[:notice] = "Please note, you are completing this order as a guest user. Please log in if you would like to associate this purchase with your account."
    end

    if @order.validate_billing_info
      @order.update(submit_date: Time.now, status: "paid")

      #TODO do this is add_product to cart stage? or here?
      # @order.order_items.each do |order_item|
      #   order_item.product.inventory -= order_item.quantity
      # end

      flash[:success] = "Thank you for shopping with Stellar!"
      session[:order_id] = nil
      render :summary, status: :success #sends user to order summary page after purchase, but needs to be render since session has been set to nil
    else
      flash.now[:error] = "Error: order was not submitted."
      @order.billing_info.errors.each { |name, message| flash.now[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash.now[:error] << "Please try again."

      render :checkout, status: :bad_request
    end

    return
  end

  private

  def order_params
    return params.require(:order).permit(:user_id, :status, :submit_date, :complete_date)
  end

  def find_order
    #should this also be creating a session if no order is found?
    @order = Order.find_by(id: session[:order_id])

    if @order.nil?
      flash.now[:error] = "There was a problem with your cart. Please clear your cookies or close your browser and revisit Stellar."
      redirect_to root_path, status: :not_found
      return
    end
  end

  def find_order_item
    current_user =  User.find_by(id: session[:user_id])
    @order_item = @order.order_items.find { |order_item| order_item.user == current_user }
  end
end
