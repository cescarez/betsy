
require "test_helper"

describe ShippingInfosController do
  let (:shipping1) { shipping_infos(:shipping1) }
  let (:shipping2) { shipping_infos(:shipping2) }
  let (:shipping3) { shipping_infos(:shipping3) }

  let (:shipping_info_hash) do
    order1 = orders(:order1)
    order1.shipping_info = shipping_infos(:shipping1)
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
    it "can create a shipping info if there are items in a cart (thus session[:order_id] exists)" do
      start_cart
      expect {
        post shipping_infos_path, params: shipping_info_hash
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
    end

    it " a shipping info if there are items in a cart (thus session[:order_id] exists)" do
      start_cart
      expect {
        post shipping_infos_path, params: shipping_info_hash
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
    end

    it "will not create a shipping_info with invalid params" do
      start_cart
      shipping_info_hash[:shipping_info][:first_name] = nil

      expect {
        post shipping_infos_path, params: shipping_info_hash
      }.wont_differ "ShippingInfo.count"

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "responds with success when accessing a valid shipping_info" do
      shipping_info = shipping_infos(:album1)
      get shipping_info_path(shipping_info.id)
      must_respond_with :success
    end

    it "responds with not_found when accessing a non-existing shipping_info" do
      get shipping_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "responds with success for an existing, valid driver" do
      shipping_info = shipping_infos(:shipping_info1)
      get edit_shipping_info_path(shipping_info.id)
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing shipping_info" do
      get edit_shipping_info_path(-1)
      must_respond_with :not_found
    end
  end

  describe "update" do

    it "will update a model with a valid post request" do
      id = ShippingInfo.first.id
      expect {
        patch shipping_info_path(id), params: new_shipping_info_hash
      }.wont_change "ShippingInfo.count"

      must_respond_with :redirect

      shipping_info = ShippingInfo.find_by(id: id)
      expect(shipping_info.title).must_equal new_shipping_info_hash[:shipping_info][:title]
      expect(shipping_info.author.name).must_equal authors(:madeleine_lengle).name
      expect(shipping_info.description).must_equal new_shipping_info_hash[:shipping_info][:description]
    end

    it "will respond with not_found for invalid ids" do
      id = -1

      expect {
        patch shipping_info_path(id), params: new_shipping_info_hash
      }.wont_change "ShippingInfo.count"

      must_respond_with :not_found
    end

    it "will not update if the params are invalid" do
      new_shipping_info_hash[:shipping_info][:title] = nil
      shipping_info = ShippingInfo.first

      expect {
        patch shipping_info_path(shipping_info.id), params: new_shipping_info_hash
      }.wont_change "ShippingInfo.count"

      shipping_info.reload # refresh the shipping_info from the database
      must_respond_with :bad_request
      expect(shipping_info.title).wont_be_nil
    end
  end

  describe "destroy" do
    it "destroys an existing shipping_info then redirects" do
      shipping_info = shipping_infos(:album1)

      expect {
        delete shipping_info_path(shipping_info.id)
      }.must_differ "ShippingInfo.count", -1

      found_shipping_info = ShippingInfo.find_by(title: shipping_info.title)

      expect(found_shipping_info).must_be_nil

      must_redirect_to shipping_infos_path

    end

    it "does not change the db when the driver does not exist, then responds with " do
      expect{
        delete shipping_info_path(-1)
      }.wont_change "ShippingInfo.count"

      must_respond_with :not_found
    end
  end
end

