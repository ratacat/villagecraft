require "has_ordering_through_meetings"

class Event < ActiveRecord::Base
  include PublicActivity::Common
  include ActiveRecord::Has::OrderingThroughMeetings
  attr_accessible :host, :title, :description, :short_title, :min_attendees, :max_attendees, :image, :price, :default_venue_uuid, :as => [:default, :system]
  attr_accessible :workshop_id, :as => :system
  has_uuid(:length => 8)
  
  belongs_to :host, :class_name => 'User'
  belongs_to :image, :class_name => 'Image'

  belongs_to :workshop
  has_many :meetings
  
  belongs_to :venue
  has_one :location, :through => :venue
  
  has_many :attendances, :dependent => :destroy do
    def with_state(state)
      where(:state => state)
    end
  end
  
  has_many :attendees, :through => :attendances, :source => :user, :uniq => true do
    def with_state(state)
      where('"attendances"."state" = ?', state)
    end
    
    def accepted
      where('"attendances"."state" IN (?)', %w(interested confirmed))
    end
  end
  
  after_initialize :generate_secret_if_missing
  normalize_attributes :title, :short_title, :description
  
  validates :workshop, :presence => true
  validates :host_id, presence: true
  validates :title, presence: true
  # validates :short_title, :length => { :minimum => 1, :maximum => 2, :message => "must contain only one or two words", :tokenizer => lambda {|s| s.split }}
  # validates :short_title, presence: true
  validates :min_attendees, 
            :numericality => { :greater_than_or_equal_to => 0, 
                               :less_than_or_equal_to => lambda {|e| e.max_attendees || e.min_attendees}, 
                               :unless => lambda {|e| e.min_attendees.blank?},
                               :only_integer => true }, 
            :presence => true
  validates :max_attendees, 
            :numericality => { :greater_than => 0, 
                               :greater_than_or_equal_to => lambda {|e| e.min_attendees || e.max_attendees}, 
                               :unless => lambda {|e| e.max_attendees.blank?},
                               :only_integer => true }, 
            :presence => true
  
  validates :description, :presence => true
  
  state_machine :initial => :published do
    event :publish do
      transition :staging => :published
    end
  end
  
  # FIXME: temporary data migration tool from Events to Workshops > Reruns (temporarilly Events) > Meetings
  def create_corresponding_workshop_and_meeting
    self.workshop = Workshop.create(:title => self.title, :description => self.description, :host => self.host)
    self.workshop.update_attribute(:image_id, self.image_id)
    self.save!
    meeting = Meeting.create(:start_time => self.start_time, :end_time => self.end_time)
    meeting.update_attribute(:venue_id, self.venue_id)
    meeting.update_attribute(:event_id, self.id)
  end
  
  def occurred? 
    self.meetings.future.count.blank?
  end

  def slots_left
    self.max_attendees - self.attendances.count # self.attendances.with_state(:attending).count
  end
  
  def locked?
    self.attendances.count > 0
  end
  
  def venue_tbd?
    self.first_meeting.try(:venue).blank?
  end
  
  def to_param
    if self.venue_tbd?
      "#{self.uuid} #{self.title}}".parameterize
    else
      "#{self.uuid} #{self.title}} in #{self.venue.location.city} #{self.venue.location.state_code}".parameterize      
    end
  end
  
  def venue
    self.first_meeting.try(:venue)
  end
  
  def default_venue_uuid
    self.venue.try(:uuid)
  end
  
  # Set venue for all descendant meetings
  def default_venue_uuid=(venue_uuid)
    v = Venue.find_by_uuid(venue_uuid)
    Meeting.update_all(["venue_id = ?", v], ["event_id = ?", self])
  end
  
  def img_src(size = :medium)
    if self.image.blank?
      Event.placeholder_src(size)
    else
      self.image.img.url(size)
    end
  end
  
  def first_meeting
    self.meetings.order(:start_time).first
  end
  
  def Event.placeholder_src(size = :medium)
#    "/assets/event_placeholder_#{size}.png"
    "/assets/event_placeholder.png"
  end
  
  def Event.auto_create_from_workshop(workshop)
    reruns = workshop.last_scheduled_reruns
    m0, m1 = reruns.map(&:first_meeting)
    
    if reruns.size > 0
      if reruns.size === 1
        # This is the second scheduled rerun, default to 1 week from the previous rerun with same duration and venue
        start_time = m0.start_time + 1.week
      else
        # There are already at least two workshops scheduled. Follow the pattern.
        start_time = m0.start_time + (m0.start_time - m1.start_time)
      end
      # Inherit everything else from m0
      end_time = start_time + m0.duration
      title = m0.event.title
      description = m0.event.description
      price = m0.event.price
      venue = m0.venue
      max_attendees = m0.event.max_attendees
    else
      # This is the first scheduled rerun, default to tomorrow @7pm
      default_tz_name = workshop.host.try(:location).try(:time_zone) || "America/Los_Angeles"
      default_tz = Time.find_zone(default_tz_name)
      start_time = Timeliness.parse("#{default_tz.now.tomorrow.to_date} 7:00pm", :zone => default_tz_name)
      end_time = start_time + 2.hours
      title = workshop.title
      description = workshop.description
      price = 0
      venue = nil
      max_attendees = 8
    end

    event = Event.create!({:title => title, 
                           :description => description, 
                           :host => workshop.host, 
                           :price => price, 
                           :max_attendees => max_attendees,
                           :workshop_id => workshop.id}, :as => :system)
    Meeting.create!({:start_time => start_time, :end_time => end_time, :venue => venue, :event_id => event.id}, :as => :system)
  end
  
  def Event.find_by_seod_uuid(id)
    Event.find_by_uuid(id.split('-').first)
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
  
end
