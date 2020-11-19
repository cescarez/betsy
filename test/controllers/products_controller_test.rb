require "test_helper"

describe ProductsController do
  describe "create products" do
    it "creates a new product" do
      @user = users(:user_1)

      expect {@product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: @user.id)}.must_change 'Product.count', 1

    end
  end
end
