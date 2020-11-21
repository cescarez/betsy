class Product < ApplicationRecord
  belongs_to :user #scope needed so only logged in users?
  has_and_belongs_to_many :categories

  validates :category, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :inventory, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :user_id, presence: true
  validates :name, uniqueness: true
end
