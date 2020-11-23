# frozen_string_literal: true
class ProductsController < ApplicationController
  before_action :find_product, only: [:add_to_cart]
  before_action :require_login, only: %i[create update edit new set_retire]
  def index
    @products = Product.all
  end

  def show
    product_id = params[:id]
    @product = Product.find_by(id: product_id)
    redirect_to products_path if @product.nil?
    if @product.nil?
      head :not_found
      nil
    end
  end

  def new
    @product = Product.new
  end

  def create
    @user = User.find_by(id: session[:user_id])
    if @user
      @product = Product.new(product_params)
      @product.user_id = @user.id
    else
      flash[:error] = 'You must create an account to access this page.'
    end
    if @product.save
      redirect_to products_path
      flash[:success] = "#{@product.name} was successfully added!"
      nil
    else
      flash.now[:error] = 'Something went wrong. Product was not added.'
      render :new, status: :bad_request
      nil
    end
  end

  def edit
    @product = Product.find_by(id: params[:id])
    if @product.nil?
      head :not_found
      flash[:error] = 'Cannot find this product.'
      nil
    end
  end

  def update
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      head :not_found
      flash.now[:error] = 'Something happened. Media not updated.'
      nil
    elsif @product.update(product_params)
      flash[:success] = "#{@product.name} was successfully updated!"
      redirect_to products_path
      nil
    end
  end

  def set_retire
    @login_user = User.find_by(id: session[:user_id]) if session[:user_id]
    @product = Product.find_by(id: params[:id])
    # if @product == @login_user.products
      @product.toggle!(:retire)
      @product.save
      redirect_back fallback_location: root_path
    # else
    #   flash[:error] = 'This is not your product.'
    #   end
  end

  # def destroy
  #   @product = Product.find_by(id: params[:id])
  #
  #   if @product.nil?
  #     head :not_found
  #     return
  #   else
  #     @product.destroy
  #     flash[:success] = "#{@product.name} was deleted"
  #     redirect_to products_path
  #     return
  #   end
  # end

  # low priority: refactor and break this method into method calls to order and only keep product-related code in products controller
  def add_to_cart
    if @product.retire == false
    quantity = params[:product][:inventory].to_i
    @order_item = OrderItem.create(product: @product, quantity: quantity)

    existing_item = nil
    if session[:order_id]
      @order = Order.find_by(id: session[:order_id])
      existing_item = @order.order_items.find { |order_item| order_item.product.name == @order_item.product.name }
    else
      @order = Order.create
    end

    if existing_item
      existing_item.quantity += quantity
      existing_item.save
    else
      @order.order_items << @order_item
    end

    if @order.order_items.find { |order_item| order_item.product.name == @order_item.product.name }
      flash[:success] = "Item #{@order.order_items.last.product.name.capitalize.to_s.gsub('_', ' ')} has been added to cart."
      session[:order_id] = @order.id

      @product.inventory -= quantity
      @product.save

      redirect_to products_path
    else
      flash[:error] = "Error: item #{@order.order_items.last.product.name.capitalize.to_s.gsub('_', ' ')} was not added to cart."
      @order.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << 'Please try again.'
      redirect_back fallback_location: root_path, status: :bad_request
    end
    else
      flash[:error] = "Sorry! This product is no longer available!"
      end
    nil
  end

  private

  def find_product
    @product = Product.find_by(id: params[:id])
  end

  def product_params
    params.require(:product).permit(:category, :name, :price, :description, :inventory, :user_id, :image)
  end
end