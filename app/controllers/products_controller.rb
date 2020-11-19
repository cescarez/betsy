class ProductsController < ApplicationController
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

  def destroy
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      head :not_found
      return
    else
      @product.destroy
      flash[:success] = "#{@product.name} was deleted"
      redirect_to products_path
      return
    end
  end

  private
  def product_params
    params.require(:product).permit(:category, :name, :price, :description, :inventory, :user_id)
  end
  end