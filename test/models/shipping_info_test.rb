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
      [:first_name, :last_name, :street, :city, :state, :zipcode, :country].each do |field|
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
      [:first_name, :last_name, :street, :city, :state, :zipcode, :country].each do |field|
        expect(shipping1.errors.messages).must_include field
      end
    end
  end

  describe "relationships" do
    it "belongs to an order" do
      expect(shipping1.order).must_equal orders(:order1)
    end
  end

  describe "custom methods" do

  end
end
