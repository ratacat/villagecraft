class InitializeCachedNextMeetingPointers < ActiveRecord::Migration
  def up
    Meeting.find_each do |m|
      m.send(:possibly_update_parents_first_meeting_cache) unless m.event.nil?
    end
  end

  def down
    Event.find_each do |e|
      e.update_attribute(:first_meeting_id, nil)
    end
  end
end
