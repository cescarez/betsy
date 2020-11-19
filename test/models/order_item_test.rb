require "test_helper"

describe OrderItem do
  let (:order_item1) do
    order_items(:order_item1)
  end
  describe "instantiation" do
    it "can instantiate an OrderItem object" do
      expect(order_item1.valid?).must_equal true
    end
    it "will have the required fields" do
      [:product_id, :quantity].each do |attribute|
        expect(order_item1).must_respond_to attribute
      end
    end

  end

  describe "validations" do
    it "order item missing a quantity will not save to db" do
      order_item1.quantity = nil
      expect(order_item1.valid?).must_equal false
    end
    it "order item with a non-numeric quantity will not save to db" do
      order_item1.quantity = "one"
      expect(order_item1.valid?).must_equal false
    end
    it "order item with a quantity < 1 will not save to db" do
      order_item1.quantity = 0
      expect(order_item1.valid?).must_equal false
      order_item1.quantity = -1
      expect(order_item1.valid?).must_equal false
    end
    it "missing attribute will be listed in validation errors" do
      order_item1.quantity = nil
      order_item1.save
      expect(order.errors.messages).must_include :quantity
    end
  end

  describe "relationships" do
    it "belongs to a product" do
      expect(order_item1.product).must_be_instance_of Product
      #TODO:to hard code expect, need Product model
      # expect(order_item1.product).must_equal
    end
  end

  describe "custom methods" do

  end
end
