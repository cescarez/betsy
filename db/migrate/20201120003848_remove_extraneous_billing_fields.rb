class RemoveExtraneousBillingFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :billing_infos, :first_name
    remove_column :billing_infos, :last_name
    remove_column :billing_infos, :street
    remove_column :billing_infos, :city
    remove_column :billing_infos, :state
    remove_column :billing_infos, :zipcode
    remove_column :billing_infos, :country
  end
end
