require "test_helper"

describe Category do
  let (:star) { categories(:star) }
  let (:planet) { categories(:planet) }
  let (:nebula) { categories(:nebula) }
  let (:moon) { categories(:moon) }
  let (:galaxy) { categories(:galaxy) }

  describe "instantiation" do
    it "can be instantiated" do
      expect(star.valid?).must_equal true
    end
    it "responds to all the expected fields" do
      [:name, :description].each do |field|
        expect(star).must_respond_to field
      end
    end
  end
  describe "validations" do
    it "will raise an error for a missing name" do
    bad_category = Category.new()

    expect(bad_category.valid?).must_equal false
    end
    it "will raise an error for a repeated name" do
      star2 = Category.new(name: "star")
      expect(star2.valid?).must_equal false
    end
  end
end
