class MeetingObserver < ActiveRecord::Observer
  include MeetingsHelper
  
  def before_update(meeting)
    if meeting.start_time_changed? or meeting.end_time_changed?
      meeting.create_activity key: 'meeting.time_changed', 
                              owner: meeting.host, 
                              parameters: {:new_time => plaintext_meeting_time(meeting)}
    end

    if meeting.venue_id_changed?
      meeting.create_activity key: 'meeting.venue_changed', 
                              owner: meeting.host, 
                              parameters: {:new_venue_id => meeting.venue_id}          
    end
    
  end
end
