class RenameBillingShippingJoinTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :shipping_infos_billing_infos, :billing_infos_shipping_infos
  end
end
