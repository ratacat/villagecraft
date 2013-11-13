class UserMailer < ActionMailer::Base
  helper :application, :users, :activities, :events, :meetings
  default from: "villagecraft@villagecraft.org"

  def confirm_attendance(attendance)
    @user = attendance.user
    @event = attendance.event
    mail(to: @user.email, subject: "You are signed up to attend: #{@event.title}")
  end
  
  def click_to_sign_in_and_attend(user, event)
    @user = user
    @event = event
    mail(to: @user.email, subject: "Confirm your sign up for: #{@event.title}")
  end
  
  def notification_email(notification)
    @notification = notification
    @user = notification.user
    mail(to: @user.email, subject: notification.to_s)    
  end
end
