class AddRsvpToEvents < ActiveRecord::Migration
  def change
    add_column :events, :rsvp, :boolean, :default => true
    add_index :events, :rsvp
  end
end
