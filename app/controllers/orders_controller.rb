class OrdersController < ApplicationController
  before_action :find_current_order, except: [:index, :create, :status_filter]
  before_action :find_order, only: [:show]
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

  #show pulls from params, all other actions pull @order from session
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

  def complete
    if @order_item
      if @order_item.update(status: "complete")
        if @order.validate_status
          @order.update(complete_date: Time.now)
        end
        flash[:success] = "#{@order_item.product.name.capitalize} in Order ##{@order.id} has marked as shipped and designated as 'complete'."
      else
        flash[:error] = "Error: #{@order_item.product.name.capitalize} in Order ##{@order.id} was not marked as shipped. Please try again."
      end
    else
      flash[:error] = "You do are not the seller for any items in Order ##{@order.id}."
    end
    redirect_back fallback_location: order_path(@order.id)
    return
  end

  def cancel
    if @order_item
      if @order_item.update(status: "cancelled")
        @order.validate_status
        flash[:success] = "#{@order_item.product.name.capitalize} in Order ##{@order.id} successfully cancelled."
      else
        flash[:error] = "Error. #{@order_item.product.name.capitalize} in Order ##{@order.id} was not cancelled. Please try again."
      end
    else
      flash[:error] = "You do are not the seller for any items in Order ##{@order.id}."
    end
    redirect_back fallback_location: order_path(@order.id)
    return
  end

  def status_filter
    status = params[:order][:status]
    current_user = User.find_by(id: session[:user_id])
    @orders = Order.filter_orders(status, current_user)
    render :index, status: :ok
    return
  end

  def submit
    @order.update_all_items(status: "pending")
    if @order.errors.any?
      flash.now[:error] = "Error occurred while updating order item status to 'pending'."
      @order.errors.each { |error| flash.now[:error] += error.full_message.join(" ") }
    end

    if session[:user_id].nil?
      flash.now[:notice] = "Please note, you are completing this order as a guest user. Please log in if you would like to associate this purchase with your account."
    end

    if @order.validate_billing_info
      @order.update(submit_date: Time.now)
      @order.update_all_items(status: "paid")
      if @order.errors.any?
        flash.now[:error] = "Error occurred while updating order item status to 'paid'."
        @order.errors.each { |error| flash.now[:error] += error.full_message.join(" ") }
      end

      flash[:success] = "Thank you for shopping with Stellar!"
      session[:order_id] = nil
      #sends user to order summary page after purchase, but needs to be render since session has been set to nil
      render :summary, status: :success
    else
      flash.now[:error] = "Error: order was not submitted for fulfillment."
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

  def find_current_order
    @order = Order.find_by(id: session[:order_id]) || Order.create
  end

  def find_order
    @order = Order.find_by(id: params[:id])

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
