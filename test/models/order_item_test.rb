require "test_helper"

describe OrderItem do
  let (:order_item1) { order_items(:order_item1) }
  let (:order_item2) { order_items(:order_item2) }
  let (:order_item3) { order_items(:order_item3) }
  let (:product1) { products(:product_1) }

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
      expect(order_item1.errors.messages).must_include :quantity
    end
  end

  describe "relationships" do
    it "belongs to a product" do
      expect(order_item1.product).must_be_instance_of Product
      expect(order_item1.product).must_equal product1
    end
  end

  describe "custom methods" do
    describe "validate quantity" do
      it "will generate a validation error for a quantity that exceeds product inventory" do
        product1.update(inventory: 4)
        order_item1.update(quantity: 6)
        order_item1.validate_quantity

        expect(order_item1.errors.messages).must_include :quantity
      end
      it "will return the quantity if less than product inventory" do
        product1.update(inventory: 5)
        order_item1.update(quantity: 4)

        expect(order_item1.validate_quantity).must_equal order_item1.quantity
      end

      it "will return the quantity if equal to product inventory" do
        product1.update(inventory: 4)
        order_item1.update(quantity: 4)

        expect(order_item1.validate_quantity).must_equal order_item1.quantity
      end
    end

  end
end
