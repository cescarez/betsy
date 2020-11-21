class User < ApplicationRecord
  has_many :products # add scope so just logged in user has products
  has_many :orders
  # has_many :order_items, through: :orders
  validates :username, uniqueness: true, presence: true
  validates :uid, uniqueness: {scope: :provider}, presence: true
  validates :email, :provider, presence: :true

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash["uid"]
    user.provider = 'github'
    user.username = auth_hash["info"]["name"]
    user.email = auth_hash["info"]["email"]
    user.avatar = auth_hash["info"]["image"]
    return user
  end

  def total_probable_earnings
    total_earnings = 0
    sold_products = self.order_items
    if sold_products.length.positive?
      sold_products.each do |sold_product|
        total_earnings += sold_product.quantity * sold_product.price
      end
    end
    return total_earnings
  end

  def total_actual_earnings
    status = %w[cancelled pending]
    total_earnings = 0
    sold_products = self.order_items
    if sold_products.length.positive?
      sold_products.each do |sold_product|
        unless sold_product.status.include?(status)
          total_earnings += sold_product.quantity * sold_product.price
        end
      end
    end
    return total_earnings
  end


end
