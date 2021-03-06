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
      mail = UserMailer.notification_email(n)
      if mail
        mail.deliver
        n.update_attribute(:emailed_at, Time.now)
        @logger.info "Notification #{n.id} about #{n.activity.key} emailed to #{n.user.email}\n"
      else
        n.destroy
        @logger.info "Notification #{n.id} about #{n.activity.key} deleted becauase trackable was deleted\n"
      end
    rescue Exception => e
      handle_exception(e)
    end
  end

  # send queued notification SMSes
  Notification.where(:sms_me => true, :smsed_at => nil).each do |n|
    begin
      response = n.user.send_sms(n.to_sms)
      n.update_attribute(:smsed_at, Time.now)
      sleep 1
    rescue Exception => e
      handle_exception(e)
    end
  end

  # send queued messages
  Message.where(:sent_at => nil).where("send_at < ?", Time.now).each do |m|
    begin
      m.deliver
      @logger.info %Q(Message #{m.id} with subject: "#{m.subject}" sent\n)
    rescue Exception => e
      handle_exception(e)
    end
  end
  
  # see whether any warmup messages need to be sent out
  Meeting.where(:sent_warmup_at => nil).where("send_warmup_at < ?", Time.now).each do |mtg|
    begin
      unless mtg.workshop.warmup_subject.blank? or mtg.workshop.warmup_body.blank?
        msg = Message.create!(
          :from_user => mtg.event.host, 
          :apropos => mtg.event,
          :subject => mtg.workshop.warmup_subject,
          :body => mtg.workshop.warmup_body)
        @logger.info %Q(Warmup message (#{msg.id}) queued for meeting (#{mtg.id})\n)        
      end
      mtg.update_attribute(:sent_warmup_at, Time.now)
    rescue Exception => e
      handle_exception(e)
    end
  end

  # see whether any reminder messages need to be sent out
  Meeting.where(:sent_reminder_at => nil).where("send_reminder_at < ?", Time.now).each do |mtg|
    begin
      unless mtg.workshop.reminder.blank?
        mtg.create_activity(key: 'meeting.reminder', owner: mtg.event.host, parameters: {:message => mtg.workshop.reminder})
        @logger.info %Q(Reminder created for meeting (#{mtg.id})\n)        
      end
      mtg.update_attribute(:sent_reminder_at, Time.now)
    rescue Exception => e
      handle_exception(e)
    end
  end

  sleep 30
end
