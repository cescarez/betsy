require "test_helper"

describe OrdersController do
  let (:user1) { users(:user_1) }
  let (:order1) { orders(:order1) }

  let (:order_hash) do
    {
      order: {
        status: "pending",
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

  end
  describe "edit" do

  end
  describe "update" do

  end
  describe "destroy" do

  end
  describe "complete" do

  end
  describe "cancel" do

  end
  describe "status_filter" do

  end
  describe "checkout" do

  end
end
