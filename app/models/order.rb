VALID_STATUSES = ["pending", "paid", "complete", "cancelled"]

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_one :shipping_info
  has_one :billing_info

  validates_date :submit_date, on_or_before: lambda { Date.current }
  validates_date :complete_date, on_or_before: lambda { Date.current }

  def validate_status
    unless VALID_STATUSES.include? self.status
      raise ArgumentError, "Invalid order status. Fatal Error. Program exiting."
    else
      return self.status
    end
  end
end
