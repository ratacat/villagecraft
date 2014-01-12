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
  
  Notification.where(:email_me => true).each do |n|
    UserMailer.notification_email(n).deliver
    n.update_attributes(:emailed_at => Time.now, :email_me => false)
    Rails.logger.info "Email about #{n.activity.key} sent to #{n.user.email}\n"
  end
  
  sleep 30
end
