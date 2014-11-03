class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.references :owner
      t.references :location

      t.timestamps
    end
    add_index :venues, :owner_id
    add_index :venues, :location_id
  end
end
