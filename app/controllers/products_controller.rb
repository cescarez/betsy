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
    @work = Work.new(work_params)
    puts @work.inspect
    puts @work.valid?
    if @work.save
      redirect_to works_path
      flash[:success] = "#{@work.title} was successfully added!"
      return
    else
      flash.now[:error] = "Something happened. Media not added."
      render :new, status: :bad_request
      return
    end
  end
end
