require "test_helper"

describe Product do
  let (:product_1) do
    products(:product_1)
  end

  describe "instantiation" do
    it "can instantiate an Product object" do
      expect(product_1.valid?).must_equal true
    end
    it "will have the required fields" do
      [:category, :name, :price, :inventory, :user_id].each do |attribute|
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
      expect(product_1.valid?).must_equal false
      product_1.inventory = -1
      expect(product_1.valid?).must_equal false
    end

    it "missing attribute will be listed in validation errors" do
      product_1.inventory = nil
      product_1.save
      expect(product.errors.messages).must_include :inventory
    end

    it "product missing a price will not save to db" do
      product_1.price = nil
      expect(product_1.valid?).must_equal false
    end

    it "order item with a non-numeric price will not save to db" do
      product_1.price = "one"
      expect(product_1.valid?).must_equal false
    end

    it "order item with an inventory < 0 will not save to db" do
      product_1.price = 0
      expect(product_1.valid?).must_equal false
      product_1.price = -1
      expect(product_1.valid?).must_equal false
    end

    it "missing attribute will be listed in validation errors" do
      product_1.price = nil
      product_1.save
      expect(product.errors.messages).must_include :price
    end
    it "product missing a category will not save to db" do
      product_1.category = nil
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
end
