require "test_helper"

describe BillingInfo do
  let (:billing1) { billing_infos(:billing1) }
  let (:billing2) { billing_infos(:billing2) }
  let (:billing3) { billing_infos(:billing3) }

  describe "instantiation" do
    it "can instantiate" do
      billing1.save
      pp billing1.errors.messages
      expect(billing1.valid?).must_equal true
    end

    it "responds to all the expected fields" do
      [:card_brand, :card_expiration, :card_number, :card_cvv].each do |field|
        expect(billing1).must_respond_to field
      end
    end
  end

  describe "validations" do
    it "must have a card brand" do
      billing1.card_brand = nil
      expect(billing1.valid?).must_equal false
    end
    it "must have a card_expiration" do
      billing1.card_expiration = nil
      expect(billing1.valid?).must_equal false
    end
    it "card_expiration must be after today" do
      billing1.card_expiration = Time.now - 1.day
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
      billing1.card_brand = nil
      billing1.card_expiration = nil
      billing1.card_number = nil
      billing1.card_cvv = nil
      billing1.save
      [:card_brand, :card_expiration, :card_number, :card_cvv].each do |field|
        expect(billing1.errors.messages).must_include field
      end
    end
  end

  describe "relationships" do
    let (:shipping1) { shipping_infos(:shipping1) }
    let (:shipping2) { shipping_infos(:shipping2) }
    let (:shipping3) { shipping_infos(:shipping3) }

    it "belongs to an order" do
      expect(billing1.order).must_equal orders(:order1)
    end

    it "can belong to many billing infos" do
      shipping1.billing_infos.delete_all
      shipping2.billing_infos.delete_all
      shipping3.billing_infos.delete_all

      shipping1.billing_infos << billing1
      shipping2.billing_infos << billing1
      shipping3.billing_infos << billing1
      expect(shipping1.billing_infos).must_include billing1
      expect(shipping2.billing_infos).must_include billing1
      expect(shipping3.billing_infos).must_include billing1
    end

    it "can have many shipping infos" do
      billing1.shipping_infos.delete_all
      billing1.shipping_infos << shipping1
      billing1.shipping_infos << shipping2
      billing1.shipping_infos << shipping3
      expect(billing1.shipping_infos.length).must_equal 3
      billing1.shipping_infos.each do |billing|
        expect(billing).must_be_instance_of ShippingInfo
      end
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
      it "will raise an exception for an invalid card brand" do
        billing1.card_brand = "apple_pay"
        billing1.save
        expect {
          billing1.validate_card_brand
        }.must_raise ArgumentError
      end
      it "will raise an exception for an empty string" do
        billing1.card_brand = ""
        billing1.save
        expect {
          billing1.validate_card_brand
        }.must_raise ArgumentError
      end
    end
  end


end
