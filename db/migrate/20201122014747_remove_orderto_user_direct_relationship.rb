class RemoveOrdertoUserDirectRelationship < ActiveRecord::Migration[6.0]
  def change
    remove_reference  :orders, :user
  end
end
