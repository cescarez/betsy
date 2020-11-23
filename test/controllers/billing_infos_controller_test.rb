require "test_helper"

describe BillingInfosController do
  let (:billing1) { billing_infos(:billing1) }
  let (:billing2) { billing_infos(:billing2) }
  let (:billing3) { billing_infos(:billing3) }

  let (:billing_info_hash) do
    order1 = orders(:order1)
    {
      billing_info: {
        order: order1,
        shipping_infos: billing1.shipping_infos,
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
      start_cart
      expect {
        post billing_infos_path, params: billing_info_hash
      }.must_differ 'BillingInfo.count', 1

      must_respond_with  :redirect
      must_redirect_to root_path
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
      billing_info = billing_infos(:album1)
      get billing_info_path(billing_info.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing billing_info" do
      get billing_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "responds with success for an existing, valid driver" do
      billing_info = billing_infos(:billing_info1)
      get edit_billing_info_path(billing_info.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing billing_info" do
      get edit_billing_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do

    it "will update a model with a valid post request" do
      id = BillingInfo.first.id
      expect {
        patch billing_info_path(id), params: new_billing_info_hash
      }.wont_change "BillingInfo.count"

      must_respond_with :redirect

      billing_info = BillingInfo.find_by(id: id)
      expect(billing_info.title).must_equal new_billing_info_hash[:billing_info][:title]
      expect(billing_info.author.name).must_equal authors(:madeleine_lengle).name
      expect(billing_info.description).must_equal new_billing_info_hash[:billing_info][:description]
    end

    it "will respond with not_found for invalid ids" do
      id = -1

      expect {
        patch billing_info_path(id), params: new_billing_info_hash
      }.wont_change "BillingInfo.count"

      must_respond_with :not_found
    end

    it "will not update if the params are invalid" do
      new_billing_info_hash[:billing_info][:title] = nil
      billing_info = BillingInfo.first

      expect {
        patch billing_info_path(billing_info.id), params: new_billing_info_hash
      }.wont_change "BillingInfo.count"

      billing_info.reload # refresh the billing_info from the database
      must_respond_with :bad_request
      expect(billing_info.title).wont_be_nil
    end
  end

  describe "destroy" do
    it "destroys an existing billing_info then redirects" do
      billing_info = billing_infos(:album1)

      expect {
        delete billing_info_path(billing_info.id)
      }.must_differ "BillingInfo.count", -1

      found_billing_info = BillingInfo.find_by(title: billing_info.title)

      expect(found_billing_info).must_be_nil

      must_redirect_to billing_infos_path

    end

    it "does not change the db when the driver does not exist, then responds with " do
      expect{
        delete billing_info_path(-1)
      }.wont_change "BillingInfo.count"

      must_respond_with :not_found
    end
  end

end
