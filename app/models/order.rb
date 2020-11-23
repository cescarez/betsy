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
        return self.status
      end
    end

    return false
  end

  def validate_billing_info
    raise ArgumentError, "Fatal Error: no billing info associated with order." if self.billing_info.nil?

    if self.billing_info.validate_card_number && self.billing_info.validate_card_brand
      return true
    else
      return false
    end
  end

  def self.filter_orders(status, current_user)
    if current_user.nil?
      raise ArgumentError, "Fatal error. Filter order status has been called and the user is not currently logged in."
    else
      if status.nil? || status.empty?
        return Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == current_user }}
      end
      status = validate_status(status)

      return Order.all.filter { |order| order.order_items.any? {|order_item| order_item.user == current_user  && order.status == status }}
    end
  end

  def total_cost
    return self.order_items.sum { |order_item| order_item.product.price * order_item.quantity }
  end

  def update_all_items(status)
    #status = self.class.validate_status(status)

    self.order_items.each do |order_item|
      order_item.update(status: status)
      if order_item.errors.any?
        messages = order_item.errors.full_messages.join(" ")
        self.errors.add(:order_item, messages)
        return false
      end
    end
    return self.update(status: status)
  end

  private

  # def self.validate_status(status)
  #   raise ArgumentError, "Invalid order status. Fatal Error." unless VALID_STATUSES.include? status
  #
  #   return status
  # end


end
