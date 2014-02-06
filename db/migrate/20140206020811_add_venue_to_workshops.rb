class AddVenueToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :venue_id, :integer
    add_index :workshops, :venue_id
  end
end
