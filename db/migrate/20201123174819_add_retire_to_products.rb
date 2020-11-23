class AddRetireToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :retire, :boolean, default: false
  end
end
