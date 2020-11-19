require 'test_helper'

describe OrdersHelper, :helper do
  describe 'hide_card' do
    it "returns a string of all asterisks except for the last four characters" do
      num = "123456789"
      hidden_num = hide_card(num)
      expect(hidden_num).must_equal "*****6789"
    end

    it "returns the input string for a string < 4 chars" do
      num = "ABC"
      hidden_num = hide_card(num)
      expect(hidden_num).must_equal "ABC"
    end
  end
end