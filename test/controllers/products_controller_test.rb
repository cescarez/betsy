require "test_helper"

describe ProductsController do
  let (:user1) { users(:user_1) }
  let (:product_1) { products(:product_1)}
  let (:product_2) { products(:product_2)}
  let (:user1) { users(:user_1) }
  let (:star) {categories(:nebula)}

  let (:product_hash) do
    {
      product: {
        name: "Starry",
        price: 200.00,
        description: "It's starry",
        inventory: 1,
        user: users(:user_1),
        retire: false,
        categories: product_1.categories
      }
    }
  end
  describe "create products" do
    it "creates a new product" do
      perform_login(users(:user_1))

      expect {post products_path, params: product_hash}.must_differ "Product.count", 1

      latest = Product.last

      must_respond_with :redirect

      expect(latest.description).must_equal product_hash[:product][:description]

    end
  end
  # describe "destroy products" do
  #   it "removes a destroyed product from the database" do
  #     user = (users(:user_1))
  #
  #     products = Product.all
  #
  #     product = Product.new(category: "planet", name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: user.id)
  #
  #     expect {product.destroy}.must_change 'Product.count', 1
  #   end
  # end
  describe "index" do
    it "responds with a success code" do
        get products_path
        must_respond_with :success
      end
  end
  describe "show" do
    it "responds with a success code" do
      product = Product.find_by(name: "Andromeda")

      get product_path(product.id)
      must_respond_with :success
    end

    it "responds with 404 for a bad id" do
      bad_id = -22

    get product_path(bad_id)

    must_respond_with :not_found
    end
  end

  describe "new" do
    it "responds with success" do
      perform_login(users(:user_1))
      get new_product_path

      must_respond_with :success
    end
  end

  describe "update" do
    it "can update a product" do
      perform_login(users(:user_1))
      product = Product.find_by(name: "Sirius")
      product.categories << star
      product.save

      expect {patch product_path(product.id), params: product_hash}.wont_change Product.count
    end
  end

  describe "edit" do
    it "responds with success" do
      perform_login(users(:user_1))
      product = Product.find_by(name: "Sirius")
      get edit_product_path(product.id)

      must_respond_with :redirect
    end

  end

  describe "add_to_cart" do
    it "it doesn't create an order if product inventory is 0" do
      product = Product.find_by(name: "Sirius")
      product.inventory = 0
      patch add_to_cart_path(product.id), params:{ product:{ inventory:2 } }
      must_respond_with :redirect
    end
    it "doesn't add a product that is retired" do
      product = Product.find_by(name: "Sirius")
      product.retire = true
      patch add_to_cart_path(product.id), params:{ product:{ inventory:2 } }
      must_respond_with :redirect
    end
    it "can create an order" do
      start_cart
      product = Product.find_by(name: "Sirius")
      order = Order.find_by(id: session[:order_id])
      patch add_to_cart_path(product.id), params:{ product:{ inventory:2 } }

      expect(order).must_be_instance_of Order
    end
    it "has an order item in cart" do
      start_cart
      product = Product.find_by(name: "Sirius")
      order = Order.find_by(id: session[:order_id])
      patch add_to_cart_path(product.id), params: { product: { inventory: 2 } }
      existing_item = order.order_items.find { |order_item| order_item.product.name == order_item.product.name }
      order.save

      expect(existing_item.quantity).must_equal 2
    end
    it "redirects if adding too many products to cart" do
      start_cart
      product = Product.find_by(name: "Sirius")
      order = Order.find_by(id: session[:order_id])
      patch add_to_cart_path(product.id), params: { product: { inventory: 2 } }
      existing_item = order.order_items.find { |order_item| order_item.product.name == order_item.product.name }
      order.save
      patch add_to_cart_path(product.id), params: { product: { inventory: 2 } }
      must_respond_with :redirect
    end

    it "increases the quantity of an already added to cart" do
      order = start_cart
      product = Product.find_by(name: "Sirius")
      patch add_to_cart_path(product.id), params: { product: { inventory: 2 } }
      existing_item = order.order_items.find { |order_item| order_item.product.name == order_item.product.name }
      patch add_to_cart_path(product.id), params: { product: { inventory: 2 } }
      must_respond_with :redirect
      existing_item = order.order_items.find { |order_item| order_item.product.name == order_item.product.name }
      expect(existing_item.quantity).must_equal before_quantity + 2
    end
  end


  describe "set retire boolean" do
    it "successfully changes the boolean" do
      perform_login(users(:user_2))
      product = Product.find_by(name: "Sirius")
      patch retire_path(product.id)
      product.reload
      expect(product.retire).must_equal true
      must_respond_with :redirect
    end
  end
end
