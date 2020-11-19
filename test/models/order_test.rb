require "test_helper"

describe Order do
  let (:order1) { orders(:order1) }

  describe "instantiation" do
    it "can instantiate" do
      expect(order1.valid?).must_equal true
    end

    it "responds to all the expected fields" do

    end
  end

  describe "validations" do
    it "must have a status" do


    end
    it  "will generate a validation error if status is missing" do

    end
  end

  describe "relationships" do
    it "can belong to a user" do

    end
    it "user can be nil at instantiation" do

    end
    it "has many order_items" do

    end
    it "has many shipping_infos" do

    end
    it "has many billing_infos" do

    end
  end

  describe "custom methods" do
    describe "validate_status" do

    end
  end
end