class CreateSightingsTable < ActiveRecord::Migration
  def change
    create_table :sightings do |t|
      t.belongs_to :location
      t.belongs_to :user
    
      t.timestamps
    end
    add_index :sightings, :location_id
    add_index :sightings, :user_id
  end
end
