class ReviewsController < ApplicationController
  #need to find product to do this?

  def create
    unless @product.nil?
      if @product.user_id == session[:user_id]
        flash[:error] = "beep boop bop...you can't leave a review for yourself...¯\\(°_o)/¯"
      else
        @review = Review.new(review_params)
        @review.product_id = @product.id
      end
    end

    result = @review.save
    if result
      flash[:success] = "Thank you for your feedback!"
    else
      flash[:error] = "Unable to leave feedback at this time!"
    end
    redirect_to request.referrer
end


  private

  def review_params
    params.require(:review).permit(:rating, :description)
  end

  # def find_product
  #   @product = Product.find_by(id: params.require(:product_id))
  # end
end
