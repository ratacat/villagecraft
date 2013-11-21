require 'has_start_and_end_time'

class Meeting < ActiveRecord::Base
  include ActiveRecord::Has::StartAndEndTime
  
  attr_accessible :start_time, :end_time, :snippet, :start_time_date, :end_time_date, :start_time_time, :end_time_time, :as => [:default, :system]
  attr_accessor :start_time_date, :end_time_date, :start_time_time, :end_time_time
  attr_accessible :venue, :event_id, :as => :system
  normalize_attributes :start_time_date, :end_time_date, :start_time_time, :end_time_time

  has_uuid(:length => 8)
  
  belongs_to :event
  has_one :host, :through => :event
  has_one :workshop, :through => :event
  belongs_to :venue
  has_one :location, :through => :venue
  
  before_validation :derive_times
  validates :event, :presence => true
  validates_datetime :end_time
  validates_datetime :start_time, :before => :end_time, :before_message => 'must be before end time'
  
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
  
  def duration
    self.end_time - self.start_time
  end
  
  protected
  def derive_times
    self.start_time = Timeliness.parse("#{self.start_time_date} #{self.start_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.start_time_time.blank?
    self.end_time = Timeliness.parse("#{self.end_time_date} #{self.end_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.end_time_time.blank?
  end
  
end