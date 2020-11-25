require "test_helper"

describe BillingInfosController do
  let (:billing1) { billing_infos(:billing1) }
  let (:billing2) { billing_infos(:billing2) }
  let (:billing3) { billing_infos(:billing3) }

  let (:order1) { orders(:order1) }

  let (:billing_info_hash) do
    {
      billing_info: {
        order: order1,
        card_number: billing1.card_number,
        card_brand: billing1.card_brand,
        card_cvv: billing1.card_cvv,
        card_expiration: billing1.card_expiration,
        email: billing1.email
      }
    }
  end

  describe "new" do
    it "can get the new_billing_info_path" do
      get new_billing_info_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a billing info if there are items in a cart (thus session[:order_id] exists)" do
      order = start_cart
      order.billing_info = billing_infos(:billing1)

      expect {
        post billing_infos_path, params: billing_info_hash
      }.must_differ 'BillingInfo.count', 1

      must_respond_with :redirect
      latest = BillingInfo.last
      expect(latest.card_number).must_equal billing1.card_number
      expect(latest.card_expiration).must_equal billing1.card_expiration
      expect(latest.card_brand).must_equal billing1.card_brand
      expect(latest.card_cvv).must_equal billing1.card_cvv
      expect(latest.email).must_equal billing1.email
    end

    it "will not create a billing_info with invalid params" do
      start_cart
      billing_info_hash[:billing_info][:card_number] = nil

      expect {
        post billing_infos_path, params: billing_info_hash
      }.must_differ "BillingInfo.count", 0

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with success when accessing a valid billing_info" do
      start_cart
      get billing_info_path(billing1.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing billing_info" do
      start_cart
      get billing_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "responds with success for an existing, valid billing info" do
      start_cart
      get edit_billing_info_path(billing1.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing billing_info" do
      start_cart
      get edit_billing_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "will update an existing billing info with a valid post request" do
      start_cart
      expect {
        patch billing_info_path(billing2.id), params: billing_info_hash
      }.wont_change "BillingInfo.count"

      must_respond_with :redirect

      billing2.reload
      expect(billing2.card_number).must_equal billing1.card_number
      expect(billing2.card_expiration).must_equal billing1.card_expiration
      expect(billing2.card_brand).must_equal billing1.card_brand
      expect(billing2.card_cvv).must_equal billing1.card_cvv
      expect(billing2.email).must_equal billing1.email
    end

    it "will respond with not_found for invalid ids" do
      start_cart
      expect {
        patch billing_info_path(-1), params: billing_info_hash
      }.wont_change "BillingInfo.count"

      must_respond_with :not_found
    end

    it "will not update if the params are invalid" do
      start_cart
      billing_info_hash[:billing_info][:card_expiration] = nil

      expect {
        patch billing_info_path(billing2.id), params: billing_info_hash
      }.wont_change "BillingInfo.count"

      billing2.reload
      must_respond_with :bad_request
      expect(billing2.card_expiration).wont_be_nil
    end
  end

  describe "destroy" do
    it "destroys an existing billing_info then redirects" do
      billing = BillingInfo.create(card_number: "378282246310005", card_brand: "visa", card_cvv: "123", card_expiration: Time.now + 3.years, email: "1234@test.com", order: order1)
      expect {
        delete billing_info_path(billing.id)
      }.must_differ "BillingInfo.count", -1

      found_billing_info = BillingInfo.find_by(card_number: billing.card_number)
      expect(found_billing_info).must_be_nil

      must_respond_with :redirect
    end

    it "does not change the db when the driver does not exist, then responds with " do
      expect{
        delete billing_info_path(-1)
      }.wont_change "BillingInfo.count"

      must_respond_with :not_found
      expect(flash[:error]).wont_be_nil
    end
  end

end
