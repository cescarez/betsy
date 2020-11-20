class RelateOrderToShippingInfo < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :shipping_infos, index: true
    add_reference :shipping_infos, :order, index: true
  end
end
