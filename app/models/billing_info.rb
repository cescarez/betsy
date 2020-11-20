VALID_CARD_BRANDS = [:visa, :mastercard, :amex]

class BillingInfo < ApplicationRecord
  belongs_to :order
  has_and_belongs_to_many :shipping_infos

  validates :card_brand, presence: true
  validates_date :card_expiration, after: :today
  validates :card_number, presence: true
  validates :card_cvv, presence: true

  def validate_card_number
    num = self.card_number.delete("\s")

    if !num || num.length <= 1 || num =~ /\D/
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
      return num
    else
      self.errors.add(:card_number, "Invalid card number. Please enter a valid card number to continue.")
    end
  end

  def validate_card_brand
    if self.brand.class == String
      self.brand = self.brand.downcase.to_sym
    end
    unless VALID_CARD_BRANDS.include? self.brand
      raise ArgumentError, "Invalid card company. Fatal Error."
    else
      return self.card_brand
    end
  end
end
