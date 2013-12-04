class DataMigrationSetAllEventsToStatePublished < ActiveRecord::Migration
  def up
    Event.find_each do |event|
      event.update_attribute(:state, 'published')
    end
  end
end
