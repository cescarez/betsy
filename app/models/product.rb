class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :user
  has_many :reviews
  has_one_attached :image
  has_many :order_items


  # validates :category, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :inventory, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :user_id, presence: true
  validates :name, uniqueness: true
end
