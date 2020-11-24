VALID_CARD_BRANDS = ["visa", "mastercard", "amex"]

class BillingInfo < ApplicationRecord
  belongs_to :order
  has_and_belongs_to_many :shipping_infos

  validates :card_brand, presence: true
  validates_date :card_expiration, after: :today
  validates :card_number, presence: true
  validates :card_cvv, presence: true
  validates :email, presence: true

  def validate_card_number
    num = self.card_number.delete("\s")

    if !num || num.length <= 1 || num =~ /\D/
      self.errors.add(:card_number, "is not valid.")
      return false
    end

    parsed_num = num.chars.reverse
    check_num = parsed_num.each_with_index.map do |char, i|
      if i.odd?
        product = char.to_i * 2
        (product >= 10) ? (product - 9) : product
      else
        char.to_i
      end
    end

    if (check_num.sum % 10 == 0)
      return self.card_number
    else
      self.errors.add(:card_number, "is not valid.")
      return false
    end
  end

  def validate_card_brand
    if VALID_CARD_BRANDS.include? self.card_brand
      return self.card_brand
    else
      self.errors.add(:card_brand, "is not valid.")
      return false
    end
  end
end
