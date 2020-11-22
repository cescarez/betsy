require "test_helper"
require "time"
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

    before do
      @user = User.new(uid: 12345, username: "Username", provider: "github", email: "email@address.com")
    end

    it "must have a username" do
      @user.username = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :username
    end
    it "must have a uid" do
      @user.uid = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :uid
    end
    it "must have an email" do
      @user.email = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :email
      end
    it "must have a provider" do
      @user.provider = nil
      expect(@user.valid?).must_equal false
      expect(@user.errors.messages).must_include :provider
    end
    it "must have a unique username" do
      @user.save!
      username = @user.username
      user_copy = User.new(username: username)
      result = user_copy.save
      expect(result).must_equal false
      expect(user_copy.errors.messages).must_include :username
    end
    it "must have a unique uid through provider" do
      @user.save!
      uid = @user.uid
      provider = @user.provider
      user_copy = User.new(uid: uid, provider: provider)
      result = user_copy.save
      expect(result).must_equal false
      expect(user_copy.errors.messages).must_include :uid
    end
    it "must be valid when created with all the required fields" do
      #user = User.new(username: "Username", uid: "12345", provider: "github", email: "email@address.com")
      expect(@user.valid?).must_equal true
    end

  end

  describe "build_from_github class method" do
    it "builds a valid user with a valid auth hash" do
      User.delete_all
      auth_hash = {
          "uid" => "12345",
          "provider" => "github",
          "info" => {
              "name" => "Name",
              "email" => "email@address.com",
              "avatar" => "not sure what to write here"
          }
      }
      user = User.build_from_github(auth_hash)
      user.save!
      expect(User.count).must_equal 1
      expect(user.uid).must_equal auth_hash["uid"]
      expect(user.provider).must_equal auth_hash["provider"]
      expect(user.username).must_equal auth_hash["info"]["name"]
      expect(user.email).must_equal auth_hash["info"]["email"]
    end
  end
  describe "earnings methods " do
    before do
      @user = User.new(uid: 12345, username: "Username", provider: "github", email: "email@address.com")
      @user.save!
      user_id = @user.id
      @product = Product.new(category: "category", name: "name", price: 100, inventory: 5, user_id: user_id)
      @product.save!
      #@order = Order.new(id: 10, user: @user, status: "pending")
      @order = Order.new(status: "pending", user_id: user_id, submit_date: Time.now, complete_date: Time.now )
      #@order_item = OrderItem.new(quantity: 1)
      @order.save!
      @order_item = @order.order_items.new(quantity: 1)
      #@order_item.product_id = @product.id
      @order_item.product = @product
      #@order.order_items << @order_item
      @order_item.save!
    end
    describe "total_probable_earnings" do

    it "accurately calculates total earnings for a seller when order status is complete" do
      @order.status = "complete"
      @order_item.save!
      expect(@user.total_probable_earnings).must_equal 100
    end

    it "accurately calculates total earnings for a seller when order status is pending" do
      @order_item.order.status = "pending"
      @order_item.save!
      expect(@user.total_probable_earnings).must_equal 100
    end

    it "accurately calculates total earnings for a seller when order status is canceled" do
      @order_item.order.status = "canceled"
      @order_item.save!
      expect(@user.total_probable_earnings).must_equal 100
    end

    it "accurately calculates total earnings for a seller when order status is paid" do
      @order_item.order.status = "paid"
      @order_item.save!
      expect(@user.total_probable_earnings).must_equal 100
    end

  end

  describe "total_actual_earnings" do
    it "accurately calculates total earnings for a seller when order status is complete" do
      @order_item.order.status = "complete"
      @order_item.save!
      expect(@user.total_actual_earnings).must_equal 100
    end

    it "accurately calculates total earnings for a seller when order status is pending" do
      @order_item.order.status = "pending"
      @order_item.save!
      expect(@user.total_actual_earnings).must_equal 0
    end

    it "accurately calculates total earnings for a seller when order status is canceled" do
      @order_item.order.status = "canceled"
      expect(@user.total_actual_earnings).must_equal 0
    end

    it "accurately calculates total earnings for a seller when order status is paid" do
      @order_item.order.status = "paid"
      @order_item.save!
      expect(@user.total_actual_earnings).must_equal 100
    end

  end
  end
end
