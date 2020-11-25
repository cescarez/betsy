require "test_helper"

describe OrdersController do
  let (:user1) { users(:user_1) }
  let (:order1) { orders(:order1) }
  let (:order2) { orders(:order2) }
  let (:order3) { orders(:order3) }
  let (:product1) { products(:product_1)}
  let (:order_item1) { order_items(:order_item1) }
  let (:order_item2) { order_items(:order_item2) }
  let (:order_item3) { order_items(:order_item3) }
  let (:billing1) {billing_infos(:billing1)}
  let (:category1) {categories(:star)}
  let (:order_hash) do
    {
      order: {
        status: "cancelled",
      }
    }
  end

  describe "index" do
    it "responds with a success code if user is logged in" do
      perform_login(user1)
      must_respond_with :success

    end

    it "responds with a redirect code if user is not logged in" do
      get orders_path
      must_respond_with :redirect
    end
  end

  describe "create" do
    it "saves a valid order and returns a redirect code" do
      expect {
        post orders_path, params: order_hash
      }.must_differ "Order.count", 1

      latest = Order.last

      must_respond_with :redirect

      expect(latest.status).must_equal order_hash[:order][:status]
    end
  end

  describe "show" do
    it "responds with a success code if there is a current shopping cart" do
      start_cart
      order = Order.find_by(id: session[:order_id])
      get order_path(order.id)
      must_respond_with :success
    end

    it "redirects to root path if there is no current shopping cart or if one is not found" do
      get order_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "can update current order with valid params" do
      start_cart
      order = Order.find_by(id: session[:order_id])

      expect {
        patch order_path(order.id), params: order_hash
      }.wont_change "Order.count"

      must_respond_with :redirect

      order.reload

      expect(order.status).must_equal order_hash[:order][:status]
    end

    it "responds with a redirect and bad_request code when updating a completed order" do
      start_cart
      order = Order.find_by(id: session[:order_id])
      order.update(complete_date: Time.now)

      expect {
        patch order_path(order.id), params: order_hash
      }.wont_change "Order.count"

      must_respond_with :redirect
    end

    it "responds with bad_request when attempting to update an existing order with invalid params" do
      start_cart
      order = Order.find_by(id: session[:order_id])

      expect {
        patch order_path(order.id), params: {order: {submit_date: Time.now + 1.year }}
      }.wont_change "Order.count"

      must_respond_with :bad_request
    end

    it "responds with not_found when attempting to update an invalid order witg valid params" do
      expect {
        patch order_path(-1), params: order_hash
      }.wont_change "Order.count"

      must_respond_with :not_found
    end
  end

  describe "complete" do
    let (:order_item1) { order_items(:order_item1) }
    let (:order_item2) { order_items(:order_item2) }

    it "updates status for order_item in order that is sold by logged in user and updates status of order and sets complete date if all order items are set to the same status" do
      new_status = "complete"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order.update(complete_date: nil)
      order_item1.update(status: "pending")
      order_item2.update(status: new_status)
      order.order_items << order_item1
      order.order_items << order_item2

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
          expect(order_item.status).must_equal new_status
      end
      expect(order.status).must_equal new_status
      expect(order.complete_date).wont_be_nil
    end

    it "updates status for order_item in order that is sold by logged in user but does not update status of order or set complete date if not all order items are the same status" do
      new_status = "complete"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order.update(complete_date: nil)
      order_item1.update(status: "pending")
      order_item2.update(status: "pending")
      order.order_items << order_item1
      order.order_items << order_item2

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
        if order_item == order_item1
          expect(order_item.status).must_equal new_status
        else
          expect(order_item.status).wont_equal new_status
        end
      end
      expect(order.status).wont_equal new_status
      expect(order.complete_date).must_be_nil
    end

    it "does not change any order item in the order, or the order status, if the logged in user does not sell any of the order items in the cart" do
      new_status = "complete"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order.update(complete_date: nil)
      order_item2.update(status: "pending")
      order.order_items << order_item2
      order.order_items << order_item2

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
        expect(order_item.status).wont_equal new_status
      end
      expect(order.status).wont_equal new_status
      expect(order.complete_date).must_be_nil
    end

    it "if no user is logged in, redirected to root" do
      new_status = "complete"
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order.update(complete_date: nil)
      order_item2.update(status: "pending")
      order.order_items << order_item2
      order.order_items << order_item2

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      must_redirect_to root_path
      order.reload

      order.order_items.each do |order_item|
        expect(order_item.status).wont_equal new_status
      end
      expect(order.status).wont_equal new_status
      expect(order.complete_date).must_be_nil
    end

    it "if no items are currently in cart (thus no session[:user_id], a no route error is raised" do
      perform_login(user1)

      expect{
        post complete_order_path(Order.find_by(id: session[:order_id]))
      }.must_raise ActionController::UrlGenerationError
    end
  end

  describe "cancel" do

    it "updates status for order_item in order that is sold by logged in user and updates status of order if all order items are set to the same status" do
      new_status = "cancelled"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order_item1.update(status: "pending")
      order_item2.update(status: new_status)
      order.order_items << order_item1
      order.order_items << order_item2

      expect{
        post cancel_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
        expect(order_item.status).must_equal new_status
      end
      expect(order.status).must_equal new_status
    end

    it "updates status for order_item in order that is sold by logged in user but does not update status of order if not all order items are the same status" do
      new_status = "cancelled"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order_item1.update(status: "pending")
      order_item2.update(status: "pending")
      order.order_items << order_item1
      order.order_items << order_item2

      expect{
        post cancel_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
        if order_item == order_item1
          expect(order_item.status).must_equal new_status
        else
          expect(order_item.status).wont_equal new_status
        end
      end
      expect(order.status).wont_equal new_status
    end

    it "does not change any order item in the order, or the order status, if the logged in user does not sell any of the order items in the cart" do
      new_status = "cancelled"
      perform_login(user1)
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order_item2.update(status: "pending")
      order.order_items << order_item2
      order.order_items << order_item2

      expect{
        post cancel_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload

      #user1 is the seller for item 1, but not item 2
      order.order_items.each do |order_item|
        expect(order_item.status).wont_equal new_status
      end
      expect(order.status).wont_equal new_status
    end

    it "if no user is logged in, redirected to root" do
      new_status = "cancelled"
      start_cart

      order = Order.find_by(id: session[:order_id])
      order.update(status: "pending")
      order_item2.update(status: "pending")
      order.order_items << order_item2
      order.order_items << order_item2

      expect{
        post cancel_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      must_redirect_to root_path
      order.reload

      order.order_items.each do |order_item|
        expect(order_item.status).wont_equal new_status
      end
      expect(order.status).wont_equal new_status
    end

    it "if no items are currently in cart (thus no session[:user_id], a no route error is raised" do
      perform_login(user1)

      expect{
        post cancel_order_path(Order.find_by(id: session[:order_id]))
      }.must_raise ActionController::UrlGenerationError
    end
  end

  describe "status_filter" do
    it "responds with :ok for any post successfully received and won't change the number of orders in the db" do
      perform_login(user1)
      expect {
        post order_status_filter_path, params: {order: {status: "cancelled"}}
        must_respond_with :ok
        post order_status_filter_path, params: {order: {status: nil}}
        must_respond_with :ok
        post order_status_filter_path, params: {order: {status: ""}}
        must_respond_with :ok
        post order_status_filter_path, params: {order: {status: "invalid_status"}}
        must_respond_with :ok
      }.wont_change "Order.count"
    end
  end

  describe "submit" do
    it "if there is valid billing info, the order submit date and status update, clears session[:order_id], and issues ok status" do
      perform_login(user1)
      start_cart
      order = Order.find_by(id: session[:order_id])
      order.billing_info = billing_infos(:billing1)
      order.update(submit_date: nil)

      expect{
        post checkout_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :ok

      order.reload

      expect(order.status).must_equal "paid"
      expect(order.submit_date).wont_be_nil

    end

    it "if there is invalid billing info, redirect back to shopping cart checkout" do
      billing1 = billing_infos(:billing1)
      billing1.update(card_number: "10000001")


      perform_login(user1)
      start_cart
      order = Order.find_by(id: session[:order_id])
      order.update(submit_date: nil)

      order.billing_info = billing1
      before_status = order.status

      expect{
        post checkout_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :bad_request

      expect(flash[:error]).to be_present
      #"Error occurred while updating order item status to 'pending'."

      order.reload

      expect(order.status).must_equal before_status
      expect(order.submit_date).must_be_nil
    end

    it "decrements the product inventory" do
      order = start_cart
      order.billing_info = billing1
      order.order_items.delete_all
      product = Product.create(categories: [category1], name: "Saturn", price: 24.95, description: "It's got rings!", inventory: 5, user_id: users(:user_1))
      order_item = OrderItem.create(product: product, quantity: 1)
      order.order_items << order_item
      before_count = product.inventory
      post checkout_order_path(order.id)
      expect(product.inventory).must_equal before_count - 1
    end
  end

  describe "edit quantity" do
    it "decrements the quantity of an item in the cart and redirects" do
      order = start_cart
      order.order_items << order_item3
      order.order_items << order_item2
      num_to_remove = 100
      expected_quantity = order_item3.quantity - num_to_remove

      expect {
        patch edit_quantity_path(order_item3.id), params: {order_item: {quantity: num_to_remove}}
      }.wont_change "OrderItem.count"

      must_respond_with :redirect

      order_item = order.order_items.find { |order_item| order_item.product.name == order_item3.product.name }
      expect(order_item.quantity).must_equal expected_quantity
    end

    it "removes the order item from the order if the quantity to be removed equals the quantity in the order" do
      order_item = OrderItem.create(product: products(:product_1), quantity: 100)
      order = start_cart
      order.order_items << order_item
      num_to_remove = order_item.quantity

      expect {
        patch edit_quantity_path(order_item.id), params: {order_item: {quantity: num_to_remove}}
      }.must_change "OrderItem.count"

      must_respond_with :redirect

      # order_item = order.order_items.find { |order_item| order_item.product.name == order_item3.product.name }
      #expect(order_item).must_be_nil

    end
    it "will not decrement if there is no active cart" do

    end
    it "will not decrement if order item to be decremented is not in active cart" do

    end
  end

end
