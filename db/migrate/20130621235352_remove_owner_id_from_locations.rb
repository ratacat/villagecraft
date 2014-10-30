class RemoveOwnerIdFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :owner_id
  end

  def down
    change_table :locations do |t|
      t.references :owner
    end
    add_index :locations, :owner_id
  end
end
