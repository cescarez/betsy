class AddColumnToBillingInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :billing_infos, :email, :string
  end
end
