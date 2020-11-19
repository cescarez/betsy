require 'test_helper'

describe ApplicationHelper, :helper do
  describe 'format_money' do
    it "when a float is input, numbers round and format as expected for USD /$\/d\/d.\/d\/d/" do
      num1 = 1234.56789
      num2 = 1.23456789
      money1 = format_money(num1)
      money2 = format_money(num2)
      expect(money1).must_match /\$[\d]+.[\d][\d]/
      expect(money2).must_match /\$[\d]+.[\d][\d]/
      expect(money1).must_equal "$1234.57"
      expect(money2).must_equal "$1.23"
    end

    it "for negative inputs and for integers, still formats as expected for USD" do
      num = -12
      money = format_money(num)
      expect(money).must_match /\$[\d]+.[\d][\d]/
      expect(money).must_equal "-$12.00"
    end

    it "returns expected USD format for zero dollars" do
      money = format_money(0)
      expect(money).must_match /\$[\d]+.[\d][\d]/
      expect(money).must_equal "$0.00"
    end

    it "returns the input for non-numerical inputs, Strings" do
      string = "onetwothree"

      expect(string).wont_match /\$[\d]+.[\d][\d]/
      expect(format_money(string)).must_equal string
    end

    it "returns nil for nil inputs" do
      expect(format_money(nil)).must_be_nil
    end
  end
end