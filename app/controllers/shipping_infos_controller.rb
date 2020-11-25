class ShippingInfosController < ApplicationController
  before_action :find_shipping_info, only: [:show, :edit, :update, :destroy]
  before_action :find_current_order, except: [:new]

  def new
    @shipping_info = ShippingInfo.new
  end

  def create
    #insecure??
    @shipping_info = ShippingInfo.new(shipping_info_params_unnested)
    # @shipping_info = ShippingInfo.new(shipping_info_params)
    @shipping_info.order = @order
    if @shipping_info.save
      flash[:success] = "Shipping info has been saved."
      if @order.update(shipping_info: @shipping_info)
        flash[:success] << " Shipping info has been associated with the current order (Order ##{@order.id})."
      else
        flash[:error] = "An error occurred and while the shipping info has been saved, it has not been associated with the current order (Order #{@order.id}). Please try again."
      end

      redirect_back fallback_location: checkout_order_path(@order.id)
      # redirect_to new_billing_info_path
    else
      flash.now[:error] = "Error: shipping info was not created."
      @shipping_info.errors.each { |name, message| flash.now[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash.now[:error] << "Please try again."
      render :new, status: :bad_request
    end
    return
  end

  def show
  end

  def edit
  end

  def update
    if @shipping_info.update(shipping_info_params)
      flash[:success] = "Shipping info has been updated."
      redirect_back fallback_location: order_path(@order.id)
    else
      flash[:error] = "Error: shipping info was not created."
      @shipping_info.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      render :edit, status: :bad_request
    end
    return
  end

  def destroy
    if @shipping_info.destroy
      flash[:success] = "Shipping info was successfully deleted."
    # TODO: delete 56 & 57? @shipping_info renders a message if @shipping_info.nil
    # else
    #   flash[:error] = "Some error occurred and shipping info was not able to be deleted. Please try again."
    end
    redirect_back fallback_location: root_path
    return
  end

  private
  def shipping_info_params
    return params.require(:shipping_info).permit(:first_name, :last_name, :street, :city, :state, :zipcode, :country)
  end

  def shipping_info_params_unnested
    return params.permit(:first_name, :last_name, :street, :city, :state, :zipcode, :country)
  end

  def find_shipping_info
    @shipping_info = ShippingInfo.find_by(id: params[:id])
    if @shipping_info.nil?
      flash[:error] = "Shipping info not found."
      render_404
      return
    end
  end

  def find_current_order
    @order = Order.find_by(id: session[:order_id])
  end
end
