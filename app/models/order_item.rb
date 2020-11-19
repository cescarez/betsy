class OrderItem < ApplicationRecord
  belongs_to :product

  #TODO: add boundedness for current product inventory. Call a product method?
  validates :quantity, presence:true, numericality: { only_integer:true, greater_than: 0 }
end
