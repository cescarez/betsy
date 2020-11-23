VALID_STATUSES = [nil, "pending", "paid", "complete", "cancelled"]

class Order < ApplicationRecord
  # belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_one :shipping_info, dependent: :delete
  has_one :billing_info, dependent: :delete

  validates_date :submit_date, on_or_before: :today, allow_nil: true
  validates_date :complete_date, on_or_before: :today, on_or_after: :submit_date, allow_nil: true

  def validate_status
    raise ArgumentError, "Invalid order status. Fatal Error." unless (VALID_STATUSES.include? self.status)

    VALID_STATUSES.each do |valid_status|
      if self.order_items.all? { |order_item| order_item.status == valid_status }
        self.update(status: valid_status)
      end
    end

    return self.status
  end

  def validate_billing_info
    raise ArgumentError, "Fatal Error: no billing info associated with order." if self.billing_info.nil?

    if billing_info.validate_card_number && billing_info.validate_card_brand
      return true
    else
      return false
    end
  end

  def self.filter_orders(status)
    current_user = User.find_by(id: session[:user_id])
    if status.nil? || status.empty?
      return Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == current_user }}
    end
    status = validate_status(status)

    return Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == current_user } && order.status == status }
  end

  def total_cost
    return self.order_items.sum { |order_item| order_item.product.price * order_item.quantity }
  end

  private


  def self.validate_status(status)
    raise ArgumentError, "Invalid order status. Fatal Error." unless VALID_STATUSES.include? status

    return status
  end

end
