class UserMailer < ActionMailer::Base
  helper :users
  default from: "villagecraft@villagecraft.org"

  def confirm_attendance(attendance)
    @user = attendance.user
    @event = attendance.event
    mail(to: @user.email, subject: "You are signed up to attend: #{@event.title}")
  end
end
