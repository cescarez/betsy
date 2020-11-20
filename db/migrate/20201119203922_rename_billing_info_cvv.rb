class RenameBillingInfoCvv < ActiveRecord::Migration[6.0]
  def change
    rename_column :billing_infos, :cvv, :card_cvv
  end
end
