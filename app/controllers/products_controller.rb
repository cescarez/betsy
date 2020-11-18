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
    @product = Product.new(product_params)
    puts @product.inspect
    puts @product.valid?
    if @product.save
      redirect_to products_path
      flash[:success] = "#{@product.title} was successfully added!"
      return
    else
      flash.now[:error] = "Something happened. Product not added."
      render :new, status: :bad_request
      return
    end
  end

  def edit
    @product = Work.find_by(id: params[:id])
    if @product.nil?
      head :not_found
      flash[:error] = "Cannot find this product."
      return
    end
  end

  def update
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      head :not_found
      flash.now[:error] = "Something happened. Media not updated."
      return
    elsif @product.update(product_params)
      flash[:success] = "#{@product.title} was successfully updated!"
      redirect_to products_path
      render :edit
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
      flash[:success] = "#{@product.title} was deleted"
      redirect_to products_path
      return
    end
  end

  private
  def product_params
    params.require(:product).permit(:category, :name, :price, :description, :inventory, :user_id)
  end
end
