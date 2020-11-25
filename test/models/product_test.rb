require "test_helper"

describe Product do
  let (:product_1) do
    products(:product_1)
  end
  let (:user1) { users(:user_1) }

  describe "instantiation" do
    it "can instantiate an Product object" do
      expect(product_1.valid?).must_equal true
    end
    it "will have the required fields" do
      [:categories, :name, :price, :inventory, :user_id].each do |attribute|
        expect(product_1).must_respond_to attribute
      end
    end

  end

  describe "validations" do
    it "product missing a inventory will not save to db" do
      product_1.inventory = nil
      expect(product_1.valid?).must_equal false
    end

    it "order item with a non-numeric inventory will not save to db" do
      product_1.inventory = "one"
      expect(product_1.valid?).must_equal false
    end

    it "order item with an inventory < 0 will not save to db" do
      product_1.inventory = 0
      expect(product_1.valid?).must_equal true
      product_1.inventory = -1
      expect(product_1.valid?).must_equal false
    end

    it "missing attribute will be listed in validation errors" do
      product_1.inventory = nil
      product_1.save
      expect(product_1.errors.messages).must_include :inventory
    end

    it "product missing a price will not save to db" do
      product_1.price = nil
      expect(product_1.valid?).must_equal false
    end

    # it "order item with a non-numeric price will not save to db" do
    #   product_1.price = "one"
    #   expect(product_1.valid?).must_equal false
    # end
    #
    # it "order item with an inventory < 0 will not save to db" do
    #   product_1.price = 0
    #   expect(product_1.valid?).must_equal true
    #   product_1.price = -1
    #   expect(product_1.valid?).must_equal false
    # end

    it "missing attribute will be listed in validation errors" do
      product_1.price = nil
      product_1.save
      expect(product_1.errors.messages).must_include :price
    end
    it "product missing a category will not save to db" do
      product_1.categories.delete_all
      expect(product_1.valid?).must_equal false
    end
    it "product missing a name will not save to db" do
      product_1.name = nil
      expect(product_1.valid?).must_equal false
    end
    it "product missing a user_id will not save to db" do
      product_1.user_id = nil
      expect(product_1.valid?).must_equal false
    end
  end

  describe "relationships" do
    it "belongs to a user" do
      product = products(:product_1)
      expect(product.user).must_equal user1
    end
  end
end
