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

def handle_exception(e)
  # This gets thrown when we need to get out.
  raise if e.kind_of? SystemExit
	
  @logger.error "Error in daemon #{__FILE__} - #{e.class.name}: #{e}"
  @logger.info e.backtrace.join("\n")
  
  ExceptionNotifier.notify_exception(e)
  
  # If something bad happened, sleep a little more so any external issues can settle down.
  Kernel.sleep 60
end

while($running) do
  # send queued notification email
  Notification.where(:email_me => true, :emailed_at => nil).each do |n|
    begin
      UserMailer.notification_email(n).deliver
      n.update_attribute(:emailed_at, Time.now)
      @logger.info "Notification #{n.id} about #{n.activity.key} emailed to #{n.user.email}\n"
    rescue Exception => e
      handle_exception(e)
    end
  end

  # send queued notification SMSes
  Notification.where(:sms_me => true, :smsed_at => nil).each do |n|
    begin
      response = n.user.send_sms(n.to_sms)
      if Rails.env.development?
        n.update_attribute(:smsed_at, Time.now)
      elsif response.ok?
        n.update_attribute(:smsed_at, Time.now)
      else
        @logger.error "Problem sending SMS notification #{n.id}: #{response.response.body}"
      end
      sleep 1
    rescue Exception => e
      handle_exception(e)
    end
  end

  sleep 30
end
