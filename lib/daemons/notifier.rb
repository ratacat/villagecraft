#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  Notification.where(:email_me => true, :emailed_at => nil).each do |n|
    UserMailer.notification_email(n).deliver
    n.update_attribute(:emailed_at, Time.now)
    Rails.logger.info "Email about #{n.activity.key} sent to #{n.user.email}\n"
  end

  Notification.where(:sms_me => true, :smsed_at => nil).each do |n|
    n.user.send_sms(n.to_sms)
    n.update_attribute(:smsed_at, Time.now)
  end
  
  sleep 30
end
