class ProductsController < ApplicationController
  before_action :find_product, only: [:add_to_cart]
  before_action :require_login, only: [:create, :update, :edit, :new]
  def index
    @products = Product.all
  end

  def show
    product_id = params[:id]
    @product = Product.find_by(id: product_id)
    if @product.nil?
      redirect_to products_path
    end
    if @product.nil?
      head :not_found
      return
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
      return
    else
      flash.now[:error] = 'Something went wrong. Product was not added.'
      render :new, status: :bad_request
      return
    end
  end

  def edit
    @product = Product.find_by(id: params[:id])
    if @product.nil?
      head :not_found
      flash[:error] = 'Cannot find this product.'
      return
    end
  end

  def update
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      head :not_found
      flash.now[:error] = 'Something happened. Media not updated.'
      return
    elsif @product.update(product_params)
      flash[:success] = "#{@product.name} was successfully updated!"
      redirect_to products_path
      return
    end
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

  def add_to_cart
    @order_item = OrderItem.create(product: @product, quantity: 1)
    @order = Order.new

    if @order.save
      flash[:success] = "First item added to cart. Welcome to Stellar."
      session[:order_id] = @order.id

      if session[:order_id].nil?
        redirect_to orders_path, action: 'create'
      end
      @order = Order.find_by(id: session[:order_id])

    else
      flash[:error] = "Error: shopping cart was not created."
      @order.errors.each { |name, message| flash[:error] << "#{name.capitalize.to_s.gsub('_', ' ')} #{message}." }
      flash[:error] << "Please try again."
      redirect_back fallback_location: root_path, status: :bad_request
    end

    @order.order_items << @order_item
    @product.inventory -= 1
    @product.save
    redirect_to products_path

    return
  end

  private

  def find_product
    @product = Product.find_by(id: params[:id])
  end

  def product_params
    params.require(:product).permit(:category, :name, :price, :description, :inventory, :user_id, :image)
  end
end