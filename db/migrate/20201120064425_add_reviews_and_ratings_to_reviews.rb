class AddReviewsAndRatingsToReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :review, :string
    add_column :reviews, :rating, :integer
  end
end
