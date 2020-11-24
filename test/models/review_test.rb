require "test_helper"

describe Review do
  let(:review) do
    Review.new(
      rating: 4,
      description: "Best Galaxy Ever!!!",
      product_id: products(:product_1).id
    )
  end

  describe "validations" do

    it "won't be valid if a description is missing" do
      review.description = nil
      value(review).wont_be :valid?
    end

    it "won't be valid if there is no rating" do
      # The rating is selected from a drop down menu and
      # will auto-select if a user doesn't choose a
      # different value
      review.rating = nil
      value(review).wont_be :valid?
    end

  end

  describe "relationships" do
    it "belongs to a product" do
      expect(review.product).must_equal products(:product_1)
    end
  end
end
