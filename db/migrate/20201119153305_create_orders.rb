class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :status
      t.datetime :submit_date
      t.datetime :complete_date

      t.timestamps
    end
  end
end
