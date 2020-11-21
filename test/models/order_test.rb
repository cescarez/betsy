require "test_helper"

describe Order do
  let (:order1) { orders(:order1) }
  let (:order2) { orders(:order2) }
  let (:order3) { orders(:order3) }
  let (:order4) { orders(:order4) }
  let (:order5) { orders(:order5) }

  describe "instantiation" do
    it "can instantiate" do
      expect(order1.valid?).must_equal true
    end

    it "responds to all the expected fields" do
      [:user_id, :status, :submit_date, :complete_date].each do |field|
        expect(order1).must_respond_to field
      end
    end
  end

  describe "validations" do
    it "must have a status" do
      order1.status = nil
      expect(order1.valid?).must_equal false
    end

    it  "will generate a validation error if status is missing" do
      order1.update(status: nil)
      expect(order1.errors.messages).must_include :status
    end
    it "will raise an exception for a future submit date" do
      order1.update(submit_date: Time.now + 1.year)
      expect(order1.errors.messages).must_include :submit_date
    end
    it "will raise an exception for a future complete date" do
      order1.update(complete_date: Time.now + 1.year)
      expect(order1.errors.messages).must_include :complete_date
    end
    it "will raise an exception for complete date that precedes the submit date" do
      order1.update(submit_date: Time.now, complete_date: Time.now - 1.day)
      expect(order1.errors.messages).must_include :complete_date
    end
  end

  describe "relationships" do
    it "can belong to a user" do
      expect(order1.user).must_equal users(:user_1)
    end
    it "user can be nil" do
      order1.user = nil
      expect(order1.valid?).must_equal true
    end
    it "has many order_items" do
      order1.order_items << order_items(:order_item1)
      order1.order_items << order_items(:order_item2)
      order1.order_items << order_items(:order_item3)
      expect(order1.order_items.count).must_equal 3
      order1.order_items.each do |item|
        expect(item).must_be_instance_of OrderItem
      end
    end
    it "has many shipping_infos" do
      order1.shipping_infos << shipping_infos(:shipping1)
      order1.shipping_infos << shipping_infos(:shipping2)
      order1.shipping_infos << shipping_infos(:shipping3)
      expect(order1.shipping_infos.count).must_equal 3
      order1.shipping_infos.each do |shipping_info|
        expect(shipping_info).must_be_instance_of ShippingInfo
      end
    end
    it "has many billing_infos" do
      order1.billing_infos << billing_infos(:billing1)
      order1.billing_infos << billing_infos(:billing2)
      order1.billing_infos << billing_infos(:billing3)
      expect(order1.billing_infos.count).must_equal 3
      order1.billing_infos.each do |billing_info|
        expect(billing_info).must_be_instance_of BillingInfo
      end
    end
  end

  describe "custom methods" do
    describe "validate_status" do
      it "will raise an exception for an invalid order status" do
        order1.status = "chillin"
        order1.save
        expect {
          order1.validate_status(order1.status)
        }.must_raise ArgumentError
      end
      it "will raise an exception for an empty string status" do
        order1.status = ""
        order1.save
        expect {
          order1.validate_status(order1.status)
        }.must_raise ArgumentError
      end
    end

    describe "filter_orders" do
      it "filters all orders on a valid status" do
        pending_orders = Order.filter_orders("pending")
        paid_orders = Order.filter_orders("paid")
        complete_orders = Order.filter_orders("complete")
        cancelled_orders = Order.filter_orders("cancelled")
        expect(pending_orders).must_include order1
        expect(pending_orders.length).must_equal 1
        expect(paid_orders).must_include order2
        expect(paid_orders.length).must_equal 1
        expect(complete_orders).must_include order3
        expect(complete_orders.length).must_equal 1
        expect(cancelled_orders).must_include order4
        expect(cancelled_orders).must_include order5
        expect(cancelled_orders.length).must_equal 2
      end

      it "returns all orders if no status is given (even though an inprogress cart has a nil status)" do
        all_orders = Order.all
        expect(Order.filter_orders("")).must_equal all_orders
        expect(Order.filter_orders(nil)).must_equal all_orders
      end

      it "will raise an exception for an invalid order status" do
        expect {
          Order.filter_orders("cotton_candy")
        }.must_raise ArgumentError
      end

    end
  end
end