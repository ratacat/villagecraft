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

@logger = ActiveSupport::BufferedLogger.new(STDERR)
# DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
@logger.level = Rails.env.production? ? Logger::INFO : Logger::DEBUG

while($running) do
  
  begin
    Notification.where(:email_me => true, :emailed_at => nil).each do |n|
      UserMailer.notification_email(n).deliver
      n.update_attribute(:emailed_at, Time.now)
      @logger.info "Email about #{n.activity.key} sent to #{n.user.email}\n"
      sleep 1
    end

    Notification.where(:sms_me => true, :smsed_at => nil).each do |n|
      n.user.send_sms(n.to_sms)
      n.update_attribute(:smsed_at, Time.now)
      sleep 1
    end
  
    sleep 30
  rescue Exception => e
    # This gets thrown when we need to get out.
    raise if e.kind_of? SystemExit
		
    @logger.error "Error in daemon #{__FILE__} - #{e.class.name}: #{e}"
    @logger.info e.backtrace.join("\n")
        
    # If something bad happened, sleep a little more so any external issues can settle down.
    Kernel.sleep 60
  end
    
end
