VALID_STATUSES = ["pending", "paid", "complete", "cancelled"]

class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :shipping_infos
  has_many :billing_infos

  validates :status, presence: true
  validates_date :submit_date, on_or_before: :today, allow_nil: true
  validates_date :complete_date, on_or_before: :today, on_or_after: :submit_date, allow_nil: true

  def validate_status(status)
    raise ArgumentError, "Invalid order status. Fatal Error." unless VALID_STATUSES.include? status

    return status
  end

  def self.filter_orders(status)
    if status.nil? || status.empty?
      return []
    end
    status = validate_status(status)

    return Order.all.filter { |order| status.include? order.status }
  end

  private

  def self.validate_status(status)
    raise ArgumentError, "Invalid order status. Fatal Error." unless (VALID_STATUSES.include? status)

    return status
  end


end
