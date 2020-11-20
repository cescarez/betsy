class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :category
      t.string :name
      t.decimal :price
      t.text :description
      t.integer :inventory
      t.integer :user_id

      t.timestamps
    end
  end
end
