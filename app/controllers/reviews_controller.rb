class ReviewsController < ApplicationController

<<<<<<< HEAD

  def new
    @review = Review.new()
=======
  def new
    @review = Review.new(review_params)
>>>>>>> master
  end

  def create
    @product = Product.find_by(id: params[:product_id])
    @user = User.find_by(id: session[:user_id])
    if !@user.nil? && @product.user_id == @user.id
      flash[:notice] = "beep boop bop...you can't leave a review for yourself...(°_o)"
      redirect_to request.referrer
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
<<<<<<< HEAD

    redirect_to product_path(@product.id)
    return
end
=======
    redirect_to request.referrer
    return
  end
>>>>>>> master


  private

  def review_params
    params.require(:review).permit(:rating, :description, :product_id)
  end

end
