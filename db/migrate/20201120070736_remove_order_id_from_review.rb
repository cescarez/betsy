class RemoveOrderIdFromReview < ActiveRecord::Migration[6.0]
  def change
    remove_column :reviews, :product_id_id
  end
end
