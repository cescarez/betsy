class ShippingInfo < ApplicationRecord
  belongs_to :order
  has_and_belongs_to_many :billing_infos, optional: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zipcode, presence: true
  validates :country, presence: true
end
