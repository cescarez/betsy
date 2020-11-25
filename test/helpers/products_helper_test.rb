require "test_helper"

describe ProductsHelper, :helper do
  let (:user1) { users(:user_1) }
  let (:product_1) { products(:product_1)}
  let (:product_2) { products(:product_2)}
  let (:user1) { users(:user_1) }
  let (:star) {categories(:nebula)}

  describe "product_retire_string" do
    it "will display 'Set Active'? if the product is retired" do
      product_1.update(retire: true)
      expect(product_1.retire).must_equal true
      string = product_retire_string(product_1)
      expect(string).must_equal "Set Active"
    end
    it "will display 'Retire <product name>' if the product is active" do
      expect(product_1.retire).must_equal false
      string = product_retire_string(product_1)
      expect(string).must_equal "Retire #{product_1.name}"
    end
  end

end