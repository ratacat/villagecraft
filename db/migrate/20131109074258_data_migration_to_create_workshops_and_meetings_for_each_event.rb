class DataMigrationToCreateWorkshopsAndMeetingsForEachEvent < ActiveRecord::Migration
  def up
    Event.find_each do |event|
      event.workshop = Workshop.create(:title => event.title, :description => event.description, :host => event.host)
      event.workshop.update_attribute(:image_id, event.image_id)
      event.save!
      meeting = Meeting.create(:start_time => event.start_time, :end_time => event.end_time)
      meeting.update_attribute(:venue_id, event.venue_id)
      meeting.update_attribute(:event_id, event.id)
    end
  end

  def down
    Workshop.find_each(&:destroy)
  end
end
