class User < ApplicationRecord
  has_many :products # add scope so just logged in user has products
  has_many :order_items, through: :products
  has_many :orders, through: :order_items
  validates :username, uniqueness: true, presence: true
  validates :uid, uniqueness: {scope: :provider}, presence: true
  validates :email, :provider, presence: :true

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash["uid"]
    user.provider = 'github'
    user.name = auth_hash["info"]["name"]
    user.username = auth_hash["info"]["name"]
    user.email = auth_hash["info"]["email"]
    user.avatar = auth_hash["info"]["image"]
    return user
  end

  def total_probable_earnings
    total_earnings = 0
    if order_items.length.positive?
      order_items.each do |sold_item|
        total_earnings += sold_item.quantity * sold_item.product.price
      end
    end
    return total_earnings
  end

  def total_actual_earnings
    statuses = %w[cancelled pending]
    total_earnings = 0
    if order_items.length.positive?
      order_items.each do |sold_item|
        unless statuses.include?(sold_item.order.status)
        total_earnings += sold_item.quantity * sold_item.product.price
        end
        end
    end
    return total_earnings
  end
end
