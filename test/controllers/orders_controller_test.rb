require "test_helper"

describe OrdersController do
  let (:order_hash) do
    {
      order: {
        user: users(:user_1),
        order_item_id: 1, #change to OrderItems
        shipping_info_id: 1, #change to ShippingInfo
        billing_info_id: 1, #change to BillingInfo
        status: "pending",
        submit_date: Time.now - 3.days,
        complete_date: Time.now,
      }
    }
  end

  describe "index" do
    #TODO: omniauth test to check if user is logged in
    it "responds with a success code if user is logged in" do

      get orders_path
      must_respond_with :redirect
    end
    it "responds with a redirect code if user is not logged in" do
      get orders_path
      must_respond_with :redirect
    end
  end

  describe "create" do

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
