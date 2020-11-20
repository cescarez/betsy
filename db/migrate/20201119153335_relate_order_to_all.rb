class RelateOrderToAll < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :user, index: true
    add_reference :orders, :order_items, index: true
    add_reference :users, :order, index: true
    add_reference :order_items, :order, index: true
  end
end
