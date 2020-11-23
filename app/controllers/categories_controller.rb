class CategoriesController < ApplicationController
  before_action :require_login, only: [:create, :new]
  def index
    @categories = Category.all
  end

  def show
    category_id = params[:id]
    @category = Category.find_by(id: category_id)
    if @category.nil?
      redirect_to categories_path
      flash[:error] = 'That category does not exist.'
      return
    end
  end

  def new
    @category = Category.new
  end

  def create
  @user = User.find_by(id: session[:user_id])
  if @user
    @category = Category.new(category_params)
  else
    flash[:error] = 'You must create an account to access this page.'
  end
  if @category.save
    redirect_to categories_path
    flash[:success] = "#{@category.name} was successfully added!"
    return
  else
    flash.now[:error] = 'Something went wrong. Category was not added.'
    render :new, status: :bad_request
    return
  end
  end
  def category_params
    params.require(:category).permit(:name, :description, {product_ids: []})
  end
end
