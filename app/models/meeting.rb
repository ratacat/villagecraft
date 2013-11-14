class Meeting < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :snippet
  has_uuid(:length => 8)
  has_start_and_end_time
  
  belongs_to :event
  has_one :host, :through => :event
  belongs_to :venue
  has_one :location, :through => :venue
  
  def time_zone
    self.location.try(:time_zone) || self.host.try(:location).try(:time_zone) || "America/Los_Angeles"
  end
  
  def find_zone
    Time.find_zone(self.time_zone)
  end
  
  def formatted_tz_offset
    self.find_zone.formatted_offset
  end
  
  def localized_start_time
    self.start_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 7:00pm", :zone => self.time_zone)
  end

  def localized_end_time
    self.end_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 9:00pm", :zone => self.time_zone)
  end
  
end
