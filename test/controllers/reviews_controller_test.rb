require "test_helper"

describe ReviewsController do
  let (:new_product) { products(:product_1) }

  describe "new" do
    it 'can access the review form' do
      get new_product_review_path(new_product.id)
      must_respond_with :success
    end
  end

  describe "create" do
    it "responds with success when a review is created" do
      #product = products(:product_1)
      perform_login(users(:user_1))
      review_hash = {
        review: {
          rating: 2,
          description: "meh",
          #product: new_product,
          product_id: new_product.id
        },
      }


      expect do
        post product_reviews_path(new_product.id), params: review_hash
      end.must_differ "Review.count", 1


      new_review = Review.find_by(description: review_hash[:review][:description])
      expect(new_review.description).must_equal review_hash[:review][:description]
      expect(new_review.rating).must_equal review_hash[:review][:rating]
      expect(new_review.product).must_equal review_hash[:review][:product]
      expect(flash[:success]).must_include "Thank you for your feedback!"

      must_respond_with :redirect
      must_redirect_to product_path(id: new_product.id)
    end
  end

end
