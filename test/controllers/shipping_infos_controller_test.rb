
require "test_helper"

describe ShippingInfosController do
  let (:shipping1) { shipping_infos(:shipping1) }
  let (:shipping2) { shipping_infos(:shipping2) }
  let (:shipping3) { shipping_infos(:shipping3) }

  let (:order1) { orders(:order1) }


  let (:shipping_info_hash) do
    {
      shipping_info: {
        order: order1,
        first_name: shipping1.first_name,
        last_name: shipping1.last_name,
        street: shipping1.street,
        city: shipping1.city,
        state: shipping1.state,
        zipcode: shipping1.zipcode,
        country: shipping1.country
      }
    }
  end

  describe "new" do
    it "can get the new_shipping_info_path" do
      get new_shipping_info_path

      must_respond_with :success
    end
  end

  describe "create" do
    let (:shipping_info_hash_unnested) do
      {
        order: order1,
        first_name: shipping1.first_name,
        last_name: shipping1.last_name,
        street: shipping1.street,
        city: shipping1.city,
        state: shipping1.state,
        zipcode: shipping1.zipcode,
        country: shipping1.country
      }
    end

    it "can create a shipping info if there are items in a cart (thus session[:order_id] exists)" do
      order = start_cart

      expect {
        post shipping_infos_path, params: shipping_info_hash_unnested
      }.must_differ 'ShippingInfo.count', 1

      must_respond_with  :redirect
      latest = ShippingInfo.last
      expect(latest.first_name).must_equal shipping1.first_name
      expect(latest.last_name).must_equal shipping1.last_name
      expect(latest.street).must_equal shipping1.street
      expect(latest.city).must_equal shipping1.city
      expect(latest.state).must_equal shipping1.state
      expect(latest.country).must_equal shipping1.country
      expect(latest.zipcode).must_equal shipping1.zipcode
      flash[:success].must_equal "Shipping info has been saved. Shipping info has been associated with the current order (Order ##{order.id})."
    end

    it "shipping info won't save if there is no current cart" do
      expect {
        post shipping_infos_path, params: shipping_info_hash
      }.wont_change 'ShippingInfo.count'
      expect(flash[:error]).wont_be_nil
      flash[:error].must_equal "Error: shipping info was not created.Order must exist.First name can't be blank.Last name can't be blank.Street can't be blank.City can't be blank.State can't be blank.Zipcode can't be blank.Country can't be blank.Please try again."
      must_respond_with :bad_request
    end

    it "will not create a shipping_info with invalid params" do

      expect {
        post shipping_infos_path, params: shipping_info_hash_unnested
      }.wont_differ "ShippingInfo.count"

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with success when accessing a valid shipping_info" do
      start_cart
      get shipping_info_path(shipping2.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing shipping_info" do
      start_cart
      get shipping_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "responds with success for an existing, valid shipping info" do
      start_cart
      get edit_shipping_info_path(shipping1.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing shipping_info" do
      start_cart
      get edit_shipping_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "will update an existing shipping info with a valid post request" do
      start_cart
      expect {
        patch shipping_info_path(shipping2.id), params: shipping_info_hash
      }.wont_change "ShippingInfo.count"

      must_respond_with :redirect

      shipping2.reload
      expect(shipping2.first_name).must_equal shipping1.first_name
      expect(shipping2.last_name).must_equal shipping1.last_name
      expect(shipping2.street).must_equal shipping1.street
      expect(shipping2.city).must_equal shipping1.city
      expect(shipping2.state).must_equal shipping1.state
      expect(shipping2.country).must_equal shipping1.country
      expect(shipping2.zipcode).must_equal shipping1.zipcode
    end

    it "will respond with not_found for invalid ids" do
      start_cart
      expect {
        patch shipping_info_path(-1), params: shipping_info_hash
      }.wont_change "ShippingInfo.count"

      must_respond_with :not_found
    end

    it "will not update if the params are invalid" do
      start_cart
      shipping_info_hash[:shipping_info][:first_name] = nil

      expect {
        patch shipping_info_path(shipping2.id), params: shipping_info_hash
      }.wont_change "ShippingInfo.count"

      shipping2.reload
      must_respond_with :bad_request
      expect(shipping2.first_name).wont_be_nil
    end
  end

  describe "destroy" do
    it "destroys an existing shipping_info then redirects" do
      shipping = ShippingInfo.create(first_name: "Test", last_name: "Person", street: "1234 st.", city: "LA", state: "CA", country: "USA", zipcode: "123214", order: order1)
      expect {
        delete shipping_info_path(shipping.id)
      }.must_differ "ShippingInfo.count", -1

      found_shipping_info = ShippingInfo.find_by(last_name: shipping.last_name)
      expect(found_shipping_info).must_be_nil

      must_respond_with :redirect
    end

    it "does not change the db when the shiping info does not exist, then responds with " do
      expect{
        delete shipping_info_path(-1)
      }.wont_change "ShippingInfo.count"

      must_respond_with :not_found
      expect(flash[:error]).wont_be_nil
      flash[:error].must_equal "Shipping info not found."
    end

    it "will respond with flash error if shipping info cannot be destroyed" do

    end
  end
end

