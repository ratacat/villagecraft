class Notifier < ActiveRecord::Observer
  observe PublicActivity::Activity

  def after_create(activity)
    case activity.trackable_type
    when 'Event'
      event = activity.trackable
      targets = event.attendees
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
      when 'event.attend'
        # FIXME: add additional targets here, e.g. friend of attendee
      when 'event.cancel_attend'
        # FIXME: consider notifying only host in case of cancellation 
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
