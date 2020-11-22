class BillingInfosController < ApplicationController
  before_action :find_billing_info, only: [:show, :edit, :update, :destroy]
  before_action :find_order

  def index
    if @user
      @billing_infos = BillingInfo.all.filter { |billing_info| billing_info.user == current_user }
    elsif @user.nil? && @order
      flash[:error] = "You must be logged in to view all billing information associated with your account."
      redirect_to order_billing_info_path(@billing_info.id)
    else
      #TODO: change this to an empty list eventually.
      @billing_infos = BillingInfo.all
    end
  end

  def new
    @billing_info = BillingInfo.new
  end

  def create
    if @billing_info.save
      flash[:success] = "Billing info has been saved."
      #TODO: associate it with order and/or user?
      # if session[:user_id]
      #   user = User.find_by(id: session[:user_id])
      #   user.billing_infos << @billing_info
      # end
      @order.billing_info = @billing_info
      redirect_back fallback_location: billing_infos(@billing_info.id)
    else
      flash[:error] = "Error: shopping cart was not created."
      @order.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      redirect_back fallback_location: , status: :bad_request
    end
    return
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
  def billing_info_params
    return params.require(:billing_info).permit(:card_number, :card_brand, :card_cvv, :card_expiration)
  end
  def find_billing_info
    @billing_info = BillingInfo.find_by(params[:id])
    if @billing_info.nil?
      flash[:error] = "Billing info not found."
      render_404
      return
    end
  end
  def find_order
    #TODO: figure out nested routes
    @order = Order.find_by(id: session[:order_id]) ||= Order.find_by(id: params[:order_id])
  end
  def find_user
    @user = User.find_by(id: session[:user_id])
  end
end
