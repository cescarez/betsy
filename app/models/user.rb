class User < ApplicationRecord
  has_many :products # add scope so just logged in user has products
  has_many :order_items, through: :products
  validates :username, uniqueness: true, presence: true
  validates :uid, uniqueness: {scope: :provider}, presence: false
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

  def total_earnings
    status = %w[cancelled pending]
    gross_earnings = 0
    sold_products = self.order_items
    if sold_products.length > 0
      sold_products.each do |sold_product|
        unless sold_product.status.include?(status)
          gross_earnings += sold_product.quantity * sold_product.price
        end
      end
      return gross_earnings
    else
      return gross_earnings
    end
  end


end
