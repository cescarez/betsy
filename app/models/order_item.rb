class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  has_one :user, through: :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def validate_status
    raise ArgumentError, "Invalid order status. Fatal Error." unless (VALID_STATUSES.include? self.status)

    return self.status
  end

end
