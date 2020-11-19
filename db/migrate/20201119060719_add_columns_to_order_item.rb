class AddColumnsToOrderItem < ActiveRecord::Migration[6.0]
  def change
    add_reference :order_items, :product, index: true
    add_column :order_items, :quantity, :integer
  end
end
