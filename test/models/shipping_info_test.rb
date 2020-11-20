require "test_helper"

describe ShippingInfo do
  let (:shipping1) { shipping_infos(:shipping1) }
  let (:shipping2) { shipping_infos(:shipping2) }
  let (:shipping3) { shipping_infos(:shipping3) }

  describe "instantiation" do
    it "can instantiate" do
      expect(shipping1.valid?).must_equal true
    end

    it "responds to all the expected fields" do
      [:order_id,:first_name, :last_name, :street, :city, :state, :zipcode, :country].each do |field|
        expect(shipping1).must_respond_to field
      end
    end
  end

  describe "validations" do
    it "must have a firstname" do
      shipping1.first_name = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have a last name" do
      shipping1.last_name = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have a street" do
      shipping1.street = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have a city" do
      shipping1.city = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have a state" do
      shipping1.state = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have  zipcode" do
      shipping1.zipcode = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must have a country" do
      shipping1.country = nil
      expect(shipping1.valid?).must_equal false
    end
    it "must generate a validation error for missing fields" do
      shipping1.first_name = nil
      shipping1.last_name = nil
      shipping1.street = nil
      shipping1.city = nil
      shipping1.state = nil
      shipping1.zipcode = nil
      shipping1.country = nil
      shipping1.save
      [:first_name, :last_name, :street, :city, :state, :zipcode, :country].each do |field|
        expect(shipping1.errors.messages).must_include field
      end
    end
  end

  describe "relationships" do
    let (:billing1) { billing_infos(:billing1) }
    let (:billing2) { billing_infos(:billing2) }
    let (:billing3) { billing_infos(:billing3) }

    it "belongs to an order" do
      expect(shipping1.order).must_equal orders(:order1)
    end

    it "can belong to many shipping infos" do
      billing1.shipping_infos.delete_all

      billing1.shipping_infos << shipping1
      billing2.shipping_infos << shipping1
      billing3.shipping_infos << shipping1
      expect(billing1.shipping_infos).must_include shipping1
      expect(billing2.shipping_infos).must_include shipping1
      expect(billing3.shipping_infos).must_include shipping1
    end

    it "can have many billing infos" do
      shipping1.billing_infos.delete_all
      shipping1.billing_infos << billing1
      shipping1.billing_infos << billing2
      shipping1.billing_infos << billing3
      expect(shipping1.billing_infos.length).must_equal 3
      shipping1.billing_infos.each do |billing|
        expect(billing).must_be_instance_of BillingInfo
      end

    end
  end

  describe "custom methods" do

  end
end
