require "test_helper"

describe ProductsController do
  describe "create products" do
    it "creates a new product" do
      @user = (users(:user_1))

      expect {@product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: @user.id)}.must_change(Product, :count).by(+1)

    end
  end
  describe "destroy products" do
    it "removes a destroyed product from the database" do
      @user = (users(:user_1))

      @products = Product.all

      @product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: @user.id)

      expect {@product.destroy}.must_change 'Product.count', 1
    end
  end
end
