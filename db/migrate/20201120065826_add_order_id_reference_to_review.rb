class AddOrderIdReferenceToReview < ActiveRecord::Migration[6.0]
  def change
    add_reference :reviews, :product_id, index: true
  end
end
