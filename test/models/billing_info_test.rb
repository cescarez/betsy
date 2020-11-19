require "test_helper"

describe BillingInfo do
  let (:billing1) { billing_infos(:billing1) }
  let (:billing2) { billing_infos(:billing2) }
  let (:billing3) { billing_infos(:billing3) }

  describe "instantiation" do
    it "can instantiate" do
      expect(billing1.valid?).must_equal true
    end

    it "responds to all the expected fields" do
      [:first_name, :last_name, :street, :city, :state, :zipcode, :country, :card_brand, :card_expiration, :card_number, :card_cvv].each do |field|
        expect(billing1).must_respond_to field
      end
    end
  end

  describe "validations" do
    it "must have a firstname" do
      billing1.first_name = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a last name" do
      billing1.last_name = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a street" do
      billing1.street = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a city" do
      billing1.city = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a state" do
      billing1.state = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have  zipcode" do
      billing1.zipcode = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a country" do
      billing1.country = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a card brand" do
      billing1.card_brand = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a card_expiration" do
      billing1.card_expiration = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a card number" do
      billing1.card_number = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a cvv" do
      billing1.card_cvv = nil
      expect(billing1.valid?).must_equal false
    end
    it "must generate a validation error for missing fields" do
      billing1.first_name = nil
      billing1.last_name = nil
      billing1.street = nil
      billing1.city = nil
      billing1.state = nil
      billing1.zipcode = nil
      billing1.country = nil
      billing1.card_brand = nil
      billing1.card_expiration = nil
      billing1.card_number = nil
      billing1.card_cvv = nil
      [:first_name, :last_name, :street, :city, :state, :zipcode, :country, :card_brand, :card_expiration, :card_number, :card_cvv].each do |field|
        expect(billing1.errors.messages).must_include field
      end
    end
  end

  describe "relationships" do
    it "belongs to an order" do
      expect(billing1.order).must_equal orders(:order1)
    end
  end

  describe "custom methods" do
    describe "validate_card_number" do
      it "will validate visa number" do
        expect(billing1.validate_card_number).must_equal billing1.card_number
      end

      it "will validate mastercard number" do
        expect(billing2.validate_card_number).must_equal billing2.card_number
      end

      it "will validate AmEx number" do
        expect(billing3.validate_card_number).must_equal billing3.card_number
      end

      it "will added a validation error if card number does not pass" do
        billing1.card_number = "1000000001"
        billing1.validate_card_number
        expect(billing1.errors.messages).must_include :card_number
      end
    end

    describe "validate_card_brand" do
      it "will accept for a valid card brand input as a string" do
        billing_info1.card_brand = "visa"
        expect(billing_info1.valid?).must_equal false
        billing_info1.validate_card_brand
        expect(billing_info1.valid?).must_equal true
      end

      it "will raise an exception for an invalid card brand" do
        billing_info1.card_brand = :apple_pay
        expect {
          billing_info1.validate_card_brand
        }.must_raise ArgumentError
      end
    end
  end


end
