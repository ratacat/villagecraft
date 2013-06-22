class AddLocationToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.references :location
    end
    add_index :users, :location_id
  end


  def down
    change_table :users do |t|
      t.remove :location_id
    end
  end
end
