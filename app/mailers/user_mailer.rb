class UserMailer < ActionMailer::Base
  helper :application, :users, :activities, :events, :meetings, :venues
  default from: "Villagecraft <notifications@villagecraft.org>"

  def confirm_attendance(attendance)
    @user = attendance.user
    @event = attendance.event
    mail(to: @user.email, subject: "You signed up to attend: #{@event.title}")
  end
  
  def click_to_sign_in_and_attend(user, event)
    @user = user
    @event = event
    mail(to: @user.email, subject: "Confirm your sign up for: #{@event.title}")
  end
  
  def notification_email(notification)
    activity = notification.activity
    @notification = notification
    @user = notification.user
    @event = 
      case activity.trackable
      when Event
        activity.trackable
      when Meeting
        activity.trackable.event
      when Workshop
        activity.trackable.next_meeting
      end
    @change = ['meeting.time_changed', 'meeting.venue_changed'].include?(activity.key)
    subject = 
      case activity.key
      when 'meeting.time_changed'
        "New Time for Villagecraft Workshop: #{@event.title}"
      when 'meeting.venue_changed'
        "New Venue for Villagecraft Workshop: #{@event.title}"
      when 'event.interested'
        "#{activity.owner.name} is interested in attending #{@event.title}"
      when "event.email"
        message_uuid = activity.parameters[:uuid]
        @message = Message.find_by_uuid(message_uuid)
        @message.subject
      else
        "Villagecraft Notification"
      end
    mail(to: @user.email, subject: subject)
  end
  
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Villagecraft")
  end
end
