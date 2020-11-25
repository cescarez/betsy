require "test_helper"

describe ProductsHelper, :helper do
  let (:user1) { users(:user_1) }
  let (:product_1) { products(:product_1)}
  let (:product_2) { products(:product_2)}
  let (:user1) { users(:user_1) }
  let (:star) {categories(:nebula)}

  let (:product_hash) do
    {
        product: {
            name: "Starry",
            price: 200.00,
            description: "It's starry",
            inventory: 1,
            user: (:user_1),
            retire: false
        }
    }
  end
  # describe "product_retire_string" do
  #   it "does not raise an error"
  #   product = Product.find_by(name: "Andromeda")
  #   expect (product_retire_string(product)).must_be_close_to "Retire #{product.name}"

  # end

end