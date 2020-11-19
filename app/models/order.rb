VALID_STATUSES = ["pending", "paid", "complete", "cancelled"]

class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items
  has_many :shipping_info
  has_many :billing_info

  validates :status, presence: true
  validates_date :submit_date, on_or_before: :today, allow_nil: true
  validates_date :complete_date, on_or_before: :today, allow_nil: true

  def validate_status
    unless VALID_STATUSES.include? self.status
      raise ArgumentError, "Invalid order status. Fatal Error. Program exiting."
    else
      return self.status
    end
  end
end
