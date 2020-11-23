require "test_helper"

describe ProductsController do
  describe "create products" do
    it "creates a new product" do
      user = (users(:user_1))

      expect {product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: user.id)}.must_change(Product, :count).by(+1)

    end
  end
  describe "destroy products" do
    it "removes a destroyed product from the database" do
      user = (users(:user_1))

      products = Product.all

      product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: user.id)

      expect {product.destroy}.must_change 'Product.count', 1
    end
  end
  describe "index" do
    it "responds with a success code" do
        get products_path
        must_respond_with :success
      end
  end
  describe "show" do
    it "responds with a success code" do
      product = products(product_1)

      get product_path(product_1.id)
      must_respond_with :success
    end

    it "responds with 404 for a bad id" do
    bad_id = -22

    get product_path(bad_id)

    must_respond_with :not_found
    end
  end
    describe "new" do

      it"responds with success" do
      get new_product_path

      must_respond_with :success
      end
    end
    describe "update" do
      it "can update a product" do
      product = products(product_1)

      expect {patch product_path(product.id)}.wont_change Product.count
    end
    end

  describe "add_to_cart" do
    it "creates an order, creates an order_item, adds order item to order, decrements product inventory" do
      product = products(:product_1)

      expect {
        patch add_to_cart_path(product.id), params:{product:{inventory:2}}
      }.must_change "Order.order_items.length", -2
    end
  end
end
