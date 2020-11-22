class BillingInfosController < ApplicationController
  before_action :find_billing_info, only: [:show, :edit, :update, :destroy]
  before_action :find_order, except: [:new]
  before_action :find_user, except: [:new]

  # def index
  #   if @user
  #     #TODO: associate it with user?
  #     # @billing_infos = BillingInfo.all.filter { |billing_info| billing_info.user == @user }
  #   elsif @user.nil? && @order
  #     flash[:error] = "You must be logged in to view all billing information associated with your account."
  #     redirect_to order_billing_info_path(@billing_info.id)
  #   else
  #     #TODO: change this to an empty list eventually.
  #     @billing_infos = BillingInfo.all
  #   end
  # end

  def new
    @billing_info = BillingInfo.new
  end

  def create
    if @billing_info.save
      flash[:success] = "Billing info has been saved."
      #TODO: associate it with user?
      # if session[:user_id]
      #   @user.billing_infos << @billing_info
      # end
      if @order.update(billing_info: @billing_info)
        flash[:success] << " Billing info has been associated with the current order (Order ##{@order.id})."
      else
        flash[:error] = "An error occurred and while the billing info has been saved, it has not been associated with the current order (Order #{@order.id}). Please try again."
      end
      redirect_back fallback_location: billing_infos(@billing_info.id)
    else
      flash[:error] = "Error: billing info was not created."
      @billing_info.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      render :new, status: :bad_request
    end
    return
  end

  def show
  end

  def edit
  end

  def update
    if @billing_info.update(billing_info_params)
      flash[:success] = "Billing info has been updated."
      redirect_back fallback_location: order_path(@order.id)
    else
      flash[:error] = "Error: billing info was not created."
      @billing_info.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      render :edit, status: :bad_request
    end
    return
  end

  def destroy
    if @billing_info.destroy
      flash[:success] = "Billing info was successfully deleted."
    else
      flash[:error] = "Some error occurred and billing info was not able to be deleted. Please try again."
    end
    redirect_back fallback_location: root_path
    return
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
    @order = Order.find_by(id: session[:order_id])
  end
  # def find_user
  #   @user = User.find_by(id: session[:user_id])
  # end
end
