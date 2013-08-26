class Event < ActiveRecord::Base
  include PublicActivity::Common
  attr_accessible :host, :course, :title, :description, :start_time_date, :end_time_date, :start_time_time, :end_time_time, :short_title, :min_attendees, :max_attendees
  attr_accessor :start_time_date, :end_time_date, :start_time_time, :end_time_time
  has_uuid(:length => 8)

  belongs_to :host, :class_name => 'User'

  belongs_to :course
  has_one :vclass, :through => :course
  
  belongs_to :venue
  has_one :location, :through => :venue
  
  has_many :attendances, :dependent => :destroy
  has_many :attendees, :through => :attendances, :source => :user, :uniq => true
  
  scope :completed, lambda { where(%{"events"."end_time" < ?}, Time.now ) }

  before_validation :derive_times, :create_course_and_vclass_if_missing, :generate_secret_if_missing
  normalize_attributes :title, :short_title, :description, :start_time_date, :end_time_date, :start_time_time, :end_time_time
  
  validates :host_id, presence: true
  validates :course_id, presence: true
  validates :title, presence: true
  validates :short_title, :length => { :minimum => 1, :maximum => 2, :message => "must contain only one or two words", :tokenizer => lambda {|s| s.split }}
  validates :short_title, presence: true
  validates :min_attendees, 
            :numericality => { :greater_than_or_equal_to => 0, 
                               :less_than_or_equal_to => lambda {|e| e.max_attendees || e.min_attendees}, 
                               :message => "must be greater than or equal to zero and less than or equal to max attendees", 
                               :unless => lambda {|e| e.min_attendees.blank?} }, 
            :presence => true
  validates :max_attendees, 
            :numericality => { :greater_than => 0, 
                               :greater_than_or_equal_to => lambda {|e| e.min_attendees || e.max_attendees}, 
                               :message => "must be greater than zero and greater than or equal to min attendees",
                               :unless => lambda {|e| e.max_attendees.blank?} }, 
            :presence => true

  validates_datetime :end_time
  validates_datetime :start_time, :before => :end_time, :before_message => 'must be before end time'
  
  validates :description, :presence => true
  
  def localized_start_time
    self.start_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 7:00pm", :zone => self.time_zone)
  end

  def localized_end_time
    self.end_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 9:00pm", :zone => self.time_zone)
  end
  
  def occurred? 
    self.start_time - Time.now < 0
  end

  def Event.starting_after(t)
    where('"events"."start_time" > ?', t )
  end

  def Event.starting_before(t)
    where('"events"."start_time" < ?', t )
  end

  def Event.ending_after(t)
    where('"events"."end_time" > ?', t )
  end

  def Event.ending_before(t)
    where('"events"."end_time" < ?', t )
  end

  def Event.future
    starting_after(Time.now)
  end
  
  def time_zone
    self.location.try(:time_zone) || self.host.location.time_zone
  end
  
  def find_zone
    Time.find_zone(self.time_zone)
  end
  
  def formatted_tz_offset
    self.find_zone.formatted_offset
  end
  
  def derive_times
    self.start_time = Timeliness.parse("#{self.start_time_date} #{self.start_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.start_time_time.blank?
    self.end_time = Timeliness.parse("#{self.end_time_date} #{self.end_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.end_time_time.blank?
  end
  
  def venue_tbd?
    self.venue.blank?
  end
  
  def to_param
    if self.venue_tbd?
      "#{self.uuid} #{self.title}}".parameterize
    else
      "#{self.uuid} #{self.title}} in #{self.venue.location.city} #{self.venue.location.state_code}".parameterize      
    end
  end
  
  protected

  def Event.random_secret
    # FIXME: this is just a placeholder
    web_colors = %w(black silver gray white maroon red purple fuchsia green lime olive yellow navy blue teal aqua)
    zodiac_animals = %w(rat ox tiger rabbit dragon snake horse goat monkey rooster dog pig)
    "#{web_colors.sample} #{zodiac_animals.sample}"
  end
  
  def generate_secret_if_missing
    if self.secret.blank?
      self.secret = Event.random_secret
    end
  end
  
  def create_course_and_vclass_if_missing
    if self.course.blank?
      vclass = Vclass.create(:title => self.title, :admin => self.host)
      self.course = Course.create(:title => self.title, :vclass => vclass)
    end
  end
end
