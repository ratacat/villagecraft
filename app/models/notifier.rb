class Notifier < ActiveRecord::Observer
  observe PublicActivity::Activity

  # FIXME: make this asynchronous to keep the site responsive 
  def after_create(activity)
    case activity.trackable_type
    when 'Event'
      event = activity.trackable
      targets = event.attendees.accepted
      targets << event.host
      case activity.key
      when 'event.time_changed'
      when 'event.create'
        # target users who have attended any of host's past events
        event.host.hostings.each do |hosted_event|
          hosted_event.attendees.each do |past_attendee|
            targets << past_attendee
          end
        end
      when 'event.interested', 'event.cancel_attend'
        # Only target host(s)
        targets = [event.host]
      when 'event.attend'
        # FIXME: add additional targets here, e.g. friend of attendee
      end
    else
      raise "Unknown trackable_type: #{activity.trackable_type}"
    end
    targets.uniq!
    targets -= [activity.owner]
    targets.each do |user|
      Notification.create(:user => user, :activity => activity)
    end
  end
end
