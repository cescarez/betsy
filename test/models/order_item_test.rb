require "test_helper"

describe OrderItem do
  let (:order_item1) { order_items(:order_item1) }
  let (:order_item2) { order_items(:order_item2) }
  let (:order_item3) { order_items(:order_item3) }
  let (:product1) { products(:product_1) }
  let (:order1) { orders(:order1) }

  describe "instantiation" do
    it "can instantiate an OrderItem object" do
      expect(order_item1.valid?).must_equal true
    end
    it "will have the required fields" do
      [:product_id, :quantity, :status].each do |attribute|
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
    it "belongs to an order" do
      expect(order_item1.order).must_be_instance_of Order
      expect(order_item1.order).must_equal orders(:order1)
    end
  end

  describe "custom methods" do
    describe "validate status" do
      it "will return the status for 'pending' status" do
        order_item1.update(status: "pending")
        order_item1.validate_status
        expect(order_item1.status).must_equal "pending"
      end

      it "will return the status for 'paid' status" do
        order_item1.update(status: "paid")
        order_item1.validate_status
        expect(order_item1.status).must_equal "paid"
      end

      it "will return the status for 'complete' status" do
        order_item1.update(status: "complete")
        order_item1.validate_status
        expect(order_item1.status).must_equal "complete"
      end

      it "will return the status for 'cancelled' status" do
        order_item1.update(status: "cancelled")
        order_item1.validate_status
        expect(order_item1.status).must_equal "cancelled"
      end

      it "will raise an argument error for an invalid status" do
        order_item1.update(status: "Invalid status")
        expect {
          order_item1.validate_status
        }.must_raise ArgumentError
      end
    end

    describe "remove_item" do
      it "decrements the quantity of an order item if it is in the cart" do
        num_to_remove = 100
        order1.order_items << order_item3
        expected_count = order_item3.quantity - num_to_remove

        order_item3.remove_item(num_to_remove, order1)
        order_item = order1.order_items.find order_item3.id
        expect(order_item.quantity).must_equal expected_count
      end
      it "will raise a no method error if a nil order is passed in (no current cart)" do
        order1 = nil
        expect {
          order_item3.remove_item(10, order1)
        }.must_raise NoMethodError
      end
    end

  end
end
