class DataMigrationSetAllEventsToStatePublished < ActiveRecord::Migration
  def up
    Event.find_each do |event|
      event.update_attribute(:state, 'published')
    end
  end
  def change
    add_column :events, :deleted_at, :datetime
    add_index :events, :deleted_at
  end
end
