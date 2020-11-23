require "test_helper"

describe Order do
  let (:order1) { orders(:order1) }
  let (:order2) { orders(:order2) }
  let (:order3) { orders(:order3) }
  let (:order4) { orders(:order4) }
  let (:order5) { orders(:order5) }

  let (:order_item1) { order_items(:order_item1) }
  let (:order_item2) { order_items(:order_item2) }
  let (:order_item3) { order_items(:order_item3) }

  let (:user1) { users(:user_1) }

  describe "instantiation" do
    it "can instantiate" do
      expect(order1.valid?).must_equal true
    end

    it "responds to all the expected fields" do
      [:status, :submit_date, :complete_date].each do |field|
        expect(order1).must_respond_to field
      end
    end
  end

  describe "validations" do
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
    it "will raise an exception for complete date but no submit date" do
      order1.update(submit_date: nil, complete_date: Time.now)
      expect(order1.errors.messages).must_include :complete_date
    end
  end

  describe "relationships" do
    it "has many order_items" do
      order1.order_items << order_item1
      order1.order_items << order_item2
      order1.order_items << order_item3
      expect(order1.order_items.count).must_equal 3
      order1.order_items.each do |item|
        expect(item).must_be_instance_of OrderItem
      end
    end
    it "has one shipping_info" do
      order1.shipping_info = shipping_infos(:shipping1)
      expect(order1.shipping_info).must_equal shipping_infos(:shipping1)
    end
    it "has many billing_infos" do
      order1.billing_info = billing_infos(:billing1)
      expect(order1.billing_info).must_equal billing_infos(:billing1)
    end
  end

  describe "custom methods" do
    describe "validate_status" do
      it "will update the order status if all order items share the same status" do
        order_item1.update(status: "complete")
        order_item2.update(status: "complete")
        order_item3.update(status: "complete")
        order1.order_items.delete_all
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        before = order1.status
        order1.validate_status
        after = order1.status
        expect(order1.status).must_equal "complete"
        expect(after).wont_equal before
      end
      it "won't change the order status if all order items don't share the same status" do
        order_item1.update(status: "complete")
        order_item2.update(status: "paid")
        order_item3.update(status: "complete")
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        order1.save
        before = order1.status
        order1.validate_status
        after = order1.status
        expect(after).must_equal before
      end
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
      it "filters all orders on a valid status and the current session user" do
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        order1.update_all_items("pending")

        pending_orders = Order.filter_orders("pending", user1)

        expect pending_orders.each do |order|
          expect([order1, order3]).must_include order
          expect(order).wont_equal order2
        end
2
      end
      it "will return nil if the currently logged in user has no orders of that status" do
        order2.order_items << order_item2
        order2.order_items << order_item2
        order2.order_items << order_item2
        order2.update_all_items("paid")
        paid_orders = Order.filter_orders("paid", user1)
        expect(paid_orders).must_be_empty
      end

      it "returns all orders associated with the logged in user if no status is given (even though an inprogress cart has a nil status)" do
        all_orders = Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == user1 }}

        expect(Order.filter_orders("", user1)).must_equal all_orders
        expect(Order.filter_orders(nil, user1)).must_equal all_orders
      end

      it "will raise an exception for an invalid order status" do
        expect {
          Order.filter_orders("cotton_candy", user1)
        }.must_raise ArgumentError
      end

      it "will raise an exception if user is not logged in" do
        expect {
          Order.filter_orders("pending", nil)
        }.must_raise ArgumentError
      end
    end

    describe "total_cost" do
      it "returns a total of all items in an order" do
        order1.order_items << order_item1
        order1.order_items << order_item2
        total_cost = order1.total_cost

        expected_cost = (order_item1.product.price * order_item1.quantity) + (order_item2.product.price * order_item2.quantity)
        expect(total_cost).must_equal expected_cost
      end

      it "returns zero for an empty order_item list" do
        order1.order_items.delete_all
        expect(order1.total_cost).must_equal 0
      end

    end

    describe "validate_billing_info" do
      it "returns true if one billing_info has valid card numbers and brands" do
        order1.billing_info = billing_infos(:billing1)
        expect(order1.validate_billing_info).must_equal true
      end

      it "returns false for invalid card number" do
        billing1 = billing_infos(:billing1)
        billing1.update(card_number: "1000000001")
        order1.billing_info = billing1
        expect(order1.validate_billing_info).must_equal false
      end

      it "returns false for an invalid card brand" do
        billing1 = billing_infos(:billing1)
        billing1.update(card_brand: "fake_company")
        order1.billing_info = billing1
        expect(order1.validate_billing_info).must_equal false
      end

      it "raises an argument error if there is no billing info attached to the order" do
        order1.billing_info = nil
        expect {
          order1.validate_billing_info
        }.must_raise ArgumentError
      end
    end

    describe "update all items" do
      it "updates all order items and the order status" do
        new_status = "complete"
        order_item1.update(status: "pending")
        order_item2.update(status: "paid")
        order_item3.update(status: "cancelled")
        order1.order_items.delete_all
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        order1.update_all_items(new_status)
        expect(order1.status).must_equal new_status
        order1.order_items.each do |order_item|
          expect(order_item.status).must_equal new_status
        end
      end

      it "generates an error validation and returns false if an order item is not able to be saved" do
        new_status = "complete"
        order_item1.update(status: "pending")
        order_item2.update(status: "paid")
        order_item3.update(status: "cancelled")
        order1.order_items.delete_all
        order_item1.quantity = 0
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        order1.update_all_items(new_status)
        expect(order1.status).wont_equal new_status
        expect(order1.order_items.any? {|order_item| order_item.status != new_status}).must_equal true
      end

      it "raises an argument error for an invalid status" do
        new_status = "invalid"
        order_item1.update(status: "pending")
        order_item2.update(status: "paid")
        order_item3.update(status: "cancelled")
        order1.order_items.delete_all
        order1.order_items << order_item1
        order1.order_items << order_item2
        order1.order_items << order_item3
        expect {
          order1.update_all_items(new_status)
        }.must_raise ArgumentError
      end
    end
  end
end