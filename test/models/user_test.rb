require "test_helper"

describe User do

  describe "relations" do

    it "has products" do
      user_1 = users(:user_1)
      expect(user_1).must_respond_to :products
      user_1.products.each do |product|
        expect(product).must_be_kind_of Product
      end
      end

    it "has order items" do
      user_1 = users(:user_1)
      expect(user_1).must_respond_to :order_items
      user_1.order_items.each do |order_item|
        expect(order_item).must_be_kind_of OrderItem
      end
    end

  end
  describe "validations" do

    it "must have a username" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end
    it "must have a uid" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :uid
    end
    it "must have an email" do
      user = User.new
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :email
    end
    it "must have a unique username" do
      username = "Username"
      user = User.new(username: username)
      user.save!
      user_copy = User.new(username: username)
      result = user_copy.save
      expect(result).must_equal false
      expect(user_copy.errors.messages).must_include :username
    end


  end



end
