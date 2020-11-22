require "test_helper"

describe OrdersController do
  let (:user1) { users(:user_1) }
  let (:order1) { orders(:order1) }
  let (:order2) { orders(:order2) }
  let (:order3) { orders(:order3) }

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

      get orders_path
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
      get order_path(order1.id)
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

    it "responds with not_found when attempting to update an invalid order with valid params" do
      expect {
        patch order_path(-1), params: order_hash
      }.wont_change "Order.count"

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "destroys an existing work then redirects" do
      start_cart
      order = Order.find_by(id: session[:order_id])

      expect {
        delete order_path(order.id)
      }.must_differ "Order.count", -1

      must_respond_with :redirect

    end

    it "does not change the db when the order does not exist, then responds with :not_found" do
      expect{
        delete order_path(-1)
      }.wont_change "Order.count"

      must_respond_with :not_found
    end
  end

  describe "complete" do
    it "updates status and complete_date for existing orders" do
      start_cart
      order = Order.find_by(id: session[:order_id])
      order.update(complete_date: nil)

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload
      expect(order.status).must_equal "complete"
      expect(order.complete_date).wont_be_nil
    end

    it "responds with :not_found for nonexisting order" do
      start_cart
      order = Order.find_by(id: session[:order_id])
      order.update(complete_date: nil)

      expect{
        post complete_order_path(-1)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload
      expect(order.status).must_equal "complete"
      expect(order.complete_date).wont_be_nil
    end
  end

  describe "cancel" do
    it "updates status and nothing else for existing orders" do
      start_cart
      order = Order.find_by(id: session[:order_id])

      expect{
        post complete_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload
      expect(order.status).must_equal "complete"
    end

    it "responds with :not_found for nonexisting order" do
      start_cart
      order = Order.find_by(id: session[:order_id])

      expect{
        post complete_order_path(-1)
      }.wont_change "Order.count"

      must_respond_with :redirect
      order.reload
      expect(order.status).must_equal "complete"
    end
  end

  describe "status_filter" do
    it "responds with :ok for any post successfully received and won't change the number of orders in the db" do
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
      order.billing_infos << billing_infos(:billing1)
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

      order.billing_infos << billing1
      before_status = order.status

      expect{
        post checkout_order_path(order.id)
      }.wont_change "Order.count"

      must_respond_with :bad_request

      order.reload

      expect(order.status).must_equal before_status
      expect(order.submit_date).must_be_nil
    end
  end
end
