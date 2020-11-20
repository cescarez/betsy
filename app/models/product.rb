class Product < ApplicationRecord
  belongs_to :user

  validates :category, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :inventory, presence: true
  validates :user_id, presence: true
  validates :name, uniqueness: true
end
