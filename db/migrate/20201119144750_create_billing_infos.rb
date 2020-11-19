class CreateBillingInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :billing_infos do |t|
      t.string :card_brand
      t.date :card_expiration
      t.string :card_number
      t.string :cvv

      t.timestamps
    end
  end
end
