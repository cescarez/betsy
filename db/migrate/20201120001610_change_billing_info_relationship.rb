class ChangeBillingInfoRelationship < ActiveRecord::Migration[6.0]
  def change
    create_table :shipping_infos_billing_infos do |t|
      t.belongs_to :shipping_info,  index:true
      t.belongs_to :billing_info,  index:true
    end
  end
end
