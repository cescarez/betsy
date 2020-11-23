module ProductsHelper
  def product_retire_string(product)
    product.retire? ? "Set Active" : "Retire #{product.name}"
  end
end
