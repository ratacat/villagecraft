class UserMailer < ActionMailer::Base
  helper :application, :users, :activities, :events, :meetings, :venues, :locations
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
  
  def message_email(message, to_email)
    @message = message
    mail(to: to_email, subject: @message.subject, reply_to: @message.from_user.email)
  end

  def system_email(message, to_email)
    @message = message
    mail(to: to_email, subject: @message.subject, reply_to: @message.from_user.email)
  end
  
  def notification_email(notification)
    activity = notification.activity
    
    # Return nil if notification concerns something that was deleted
    if activity.trackable.nil?
      return nil
    end
    
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
      else
        "Villagecraft Notification"
      end
    if @event and @event.try(:host).try(:email)
      mail(to: @user.email, subject: subject, reply_to: @event.host.email)
    else
      mail(to: @user.email, subject: subject)
    end
  end
end
