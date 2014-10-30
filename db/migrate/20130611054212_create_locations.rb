class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :street
      t.string :city
      t.string :zip
      t.string :state
      t.references :owner
      t.string :name

      t.timestamps
    end
    add_index :locations, :owner_id
  end
end
