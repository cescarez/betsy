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

    it "does not post an invalid and responds with bad_request" do
      expect {
        post orders_path, params: {order:{status: nil}}
      }.wont_change "Order.count"

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with a success code" do
      get order_path(order1.id)
      must_respond_with :success
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
        patch order_path(order.id), params: {order: {status: nil, }}
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
      expect {
        delete order_path(order1.id)
      }.must_differ "Order.count", -1

      found_order = Order.find_by(id: order1.id)

      expect(found_order).must_be_nil

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
      expect(order.complete_date).wont_be_nil
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
      expect(order.complete_date).wont_be_nil
    end
  end

  describe "status_filter" do
    it "responds with :ok for any post successfully received" do
      post order_status_filter_path, params: {order: {status: "cancelled"}}
      must_respond_with :ok

      post order_status_filter_path, params: {order: {status: nil}}
      must_respond_with :ok

      post order_status_filter_path, params: {order: {status: ""}}
      must_respond_with :ok

      post order_status_filter_path, params: {order: {status: "invalid_status"}}
      must_respond_with :ok
    end
  end

  describe "submit" do

  end
end
