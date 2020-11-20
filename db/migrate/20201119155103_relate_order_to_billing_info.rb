class RelateOrderToBillingInfo < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :billing_infos, index: true
    add_reference :billing_infos, :order, index: true
  end
end
