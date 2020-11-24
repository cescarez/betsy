class ReviewsController < ApplicationController

  def new
    @review = Review.new()

  end

  def create
    @product = Product.find_by(id: params[:product_id])
    @user = User.find_by(id: session[:user_id])
    if !@user.nil? && @product.user_id == @user.id
      flash[:notice] = "beep boop bop...you can't leave a review for yourself...(°_o)"
      redirect_to product_path(@product.id)
      return
    end

    @review = Review.new(review_params)
    @review.product_id = @product.id
    result = @review.save

    if result
      flash[:success] = "Thank you for your feedback!"
    else
      flash[:error] = "Unable to leave feedback at this time!"
    end


    redirect_to product_path(@product.id)
    return

    # redirect_to request.referrer
    # return
  end



  private

  def review_params
    params.require(:review).permit(:rating, :description, :products)
  end

end
