class RenameReviewToDescription < ActiveRecord::Migration[6.0]
  def change
    rename_column :reviews, :review, :description
  end
end
