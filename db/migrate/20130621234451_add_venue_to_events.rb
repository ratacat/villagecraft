class AddVenueToEvents < ActiveRecord::Migration
  def up
    change_table :events do |t|
      t.references :venue
    end
    add_index :events, :venue_id
  end


  def down
    change_table :events do |t|
      t.remove :venue_id
    end
  end
end
