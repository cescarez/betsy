class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :username
      t.string :name
      t.string :provider
      t.string :email
      t.boolean :is_authenticated
      t.string :avatar

      t.timestamps
    end
  end
end
