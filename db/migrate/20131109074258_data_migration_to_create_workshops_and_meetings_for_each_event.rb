class DataMigrationToCreateWorkshopsAndMeetingsForEachEvent < ActiveRecord::Migration
  def up
    Event.find_each do |event|
      event.create_corresponding_workshop_and_meeting
    end
  end

  def down
    Workshop.find_each(&:destroy)
  end
end
