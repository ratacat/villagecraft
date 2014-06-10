require "has_ordering_through_meetings"

class Event < ActiveRecord::Base
  include PublicActivity::Common
  include ActiveRecord::Has::OrderingThroughMeetings
  attr_accessible :host, :title, :description, :short_title, :min_attendees, :max_attendees, :image, :price,
                  :venue_uuid, :external, :external_url, :rsvp,
                  :start_time, :end_time, :start_time_date, :end_time_date, :start_time_time, :end_time_time,
                  :address, :cost_type, :end_price, :organization_ids, :info_url,
                  :as => [:default, :system]
  attr_accessor :start_time_date, :end_time_date, :start_time_time, :end_time_time
  attr_accessible :workshop_id, :venue, :uuid, :as => :system
  normalize_attributes :start_time_date, :end_time_date, :start_time_time, :end_time_time

  has_uuid(:length => 8)
  acts_as_paranoid

  belongs_to :host, :class_name => 'User'
  belongs_to :image, :class_name => 'Image'

  belongs_to :workshop
  has_many :meetings, :dependent => :destroy, :conditions => {:deleted_at => nil}
  belongs_to :first_meeting, :class_name => 'Meeting'
  
  belongs_to :venue
  has_one :location, :through => :venue
  
  has_many :reviews, :as => :apropos, :dependent => :destroy, :conditions => {:deleted_at => nil}

  has_many :event_organizations
  has_many :organizations, through: :event_organizations

  has_many :attendances, :dependent => :destroy, :conditions => {:deleted_at => nil} do
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
  
  UNLOCK_TIMEOUT = 5 # minutes that unlocking lasts
  COST_TYPE = [:free, :donation, :set_price, :sliding_scale]
  COST_TYPE_LABEL = { free: "Free", donation: "Donation", set_price: "Set price", sliding_scale: "Sliding scale" }
  
  after_initialize :generate_secret_if_missing
  normalize_attributes :title, :short_title, :description
  before_validation :derive_times
  before_save :propogate_changes_to_dependant_meetings
  after_save :touch_to_expire_cached_fragments, :propogate_changes_to_parent_workshop
  
  validates :workshop, presence: true
  validates :host_id, presence: true
  validates :title, presence: true
  validates :external_url, url: {allow_blank: true}
  validates :info_url, url: {allow_blank: true}
  validates :cost_type, inclusion: COST_TYPE + COST_TYPE.collect{|x| x.to_s}
  # validates :short_title, :length => { :minimum => 1, :maximum => 2, :message => "must contain only one or two words", :tokenizer => lambda {|s| s.split }}
  # validates :short_title, presence: true
  validates :min_attendees, 
            :numericality => { :greater_than_or_equal_to => 0, 
                               :less_than_or_equal_to => lambda {|e| e.max_attendees || e.min_attendees}, 
                               :less_than => 1000000,
                               :unless => lambda {|e| e.min_attendees.blank?},
                               :only_integer => true }, 
            :presence => true
  validates :max_attendees, 
            :numericality => { :greater_than => 0, 
                               :greater_than_or_equal_to => lambda {|e| e.min_attendees || e.max_attendees}, 
                               :less_than => 1000000,
                               :unless => lambda {|e| e.max_attendees.blank?},
                               :only_integer => true }, 
            :presence => true
  
  # validates :description, :presence => true
  
  state_machine :initial => :published do
    event :publish do
      transition :staging => :published
    end
  end
  
  # FIXME: temporary data migration tool from Events to Workshops > Reruns (temporarilly Events) > Meetings
  def create_corresponding_workshop_and_meeting
    self.workshop = Workshop.create({:title => self.title, :description => self.description, :host => self.host}, :without_protection => true)
    self.workshop.update_attribute(:image_id, self.image_id)
    self.save!
    meeting = Meeting.create(:start_time => self.start_time, :end_time => self.end_time)
    meeting.update_attribute(:venue_id, self.venue_id)
    meeting.update_attribute(:event_id, self.id)
  end

  def create_corresponding_workshop
    self.workshop = Workshop.create({:title => self.title, :description => self.description, :host => self.host}, :without_protection => true)
    self.workshop.update_attribute(:image_id, self.image_id)
    self.save!
  end
  
  def occurred? 
    self.meetings.future.count === 0
  end

  def slots_left
    self.max_attendees - self.attendances.count # self.attendances.with_state(:attending).count
  end
  alias :spots_left :slots_left
  
  def full?
    self.rsvp? and self.spots_left <= 0
  end
  
  def attended?
    self.attendances.count > 0
  end
  
  def locked?
    self.attended? and (self.unlocked_at.nil? or self.unlocked_at < Event::UNLOCK_TIMEOUT.minutes.ago)
  end
  
  def venue_tbd?
    self.try(:venue).blank?
  end
  
  def to_param
    if self.venue_tbd?
      "#{self.uuid} #{self.title}}".parameterize
    else
      "#{self.uuid} #{self.title}} in #{self.venue.location.city} #{self.venue.location.state_code}".parameterize      
    end
  end
  
  def venue_uuid
    self.venue.try(:uuid)
  end
  
  def venue_uuid=(venue_uuid)
    v = Venue.find_by_uuid(venue_uuid)
    self.update_attribute(:venue_id, v.try(:id))
  end
  
  def img_src(size = :medium)
    if self.image.blank?
      Event.placeholder_src(size)
    else
      self.image.i.url(size)
    end
  end

  def time_zone
    self.location.try(:time_zone) || self.host.try(:location).try(:time_zone) || "America/Los_Angeles"
  end

  def find_zone
    Time.find_zone(self.time_zone)
  end

  def localized_start_time
    self.start_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 7:00pm", :zone => self.time_zone)
  end

  def localized_end_time
    self.end_time.try(:in_time_zone, self.time_zone) || Timeliness.parse("#{self.find_zone.now.tomorrow.to_date} 9:00pm", :zone => self.time_zone)
  end

  def derive_times
    self.start_time = Timeliness.parse("#{self.start_time_date} #{self.start_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.start_time_time.blank?
    self.end_time = Timeliness.parse("#{self.end_time_date} #{self.end_time_time}", :zone => self.time_zone) unless self.start_time_date.blank? or self.end_time_time.blank?
  end

  def address
    ""
  end

  def address=(v)

  end
  
  def manageable?
    not self.external? and self.rsvp?
  end

  def first_meeting
    if fm_id = self.read_attribute(:first_meeting_id)
      Meeting.find(fm_id)
    else
      # if for some reason the first_meeting pointer is missing, figure it out and cache it
      fm = self.meetings.order(:start_time).first
      self.update_attribute(:first_meeting_id, fm.try(:id))
      fm
    end
  end

  def cache_key(context = nil)
    if context
      "event-#{context}-#{self.uuid}-#{self.updated_at.to_i}"
    else
      "event-#{self.uuid}-#{self.updated_at.to_i}"
    end
  end

  def self.first_meeting_in_the_future
    # I think, should be like that
    # joins(:meetings).where('meetings.end_time > ?', Time.now)
    joins(:meetings).where(%Q(#{Meeting.quoted_table_column(:end_time)} > ?), Time.now)
  end

  def self.first_meeting_in_the_past
    joins(:meetings).where(%Q(#{Meeting.quoted_table_column(:end_time)} < ?), Time.now)
  end

  def self.by_distance_from(l)
    # get spheroid distance in meters
    dist_q = %{ST_Distance_Spheroid( #{Location.quoted_table_column(:point)}, ST_GeomFromText('POINT(#{l.longitude} #{l.latitude})', 4326), 'SPHEROID["WGS 84",6378137,298.257223563]')};
    joins(:location).select(%{"events".*, (#{dist_q}) AS dist}).order(:dist)
  end


  def Event.placeholder_src(size = :medium)
#    "/assets/event_placeholder_#{size}.png"
    "/assets/event_placeholder.png"
  end
  
  def Event.auto_create_from_workshop(workshop)
    reruns = workshop.last_scheduled_reruns
    meetings = reruns.map(&:first_meeting).compact
    m0, m1 = meetings
    
    if meetings.size > 0
      if meetings.size === 1
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
      rsvp = m0.event.rsvp
      if external = m0.event.external
        external_url = m0.event.external_url.blank? ? workshop.external_url : m0.event.external_url
      else
        external_url = nil
      end
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
      rsvp = true
      external = workshop.external
      external_url = workshop.external_url
    end
        
    # don't allow new rerun to start in the past
    if start_time < Time.now
      duration = end_time - start_time
      weeks_ago = (((Time.now) - start_time)/(7*24*60*60)).ceil
      start_time += weeks_ago.weeks
      end_time = start_time + duration
    end
    event = Event.create!({:title => title, 
                           :description => description, 
                           :host => workshop.host, 
                           :price => price.to_i, 
                           :venue => venue, 
                           :max_attendees => max_attendees,
                           :rsvp => rsvp,
                           :external => external,
                           :external_url => external_url,
                           :workshop_id => workshop.id}, :as => :system)
    Meeting.create!({:start_time => start_time, :end_time => end_time, :venue => venue, :event_id => event.id}, :as => :system)
  end
  
  def Event.find_by_seod_uuid!(id)
    Event.find_by_uuid!(id.split('-').first)
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
  
  def propogate_changes_to_dependant_meetings
    if self.venue_id_changed?
      self.meetings.find_each do |meeting|
        meeting.update_attribute(:venue_id, self.venue_id)
      end
    end
  end

  def touch_to_expire_cached_fragments
    if self.workshop.present?
      self.workshop.touch
    end
  end
  
  def propogate_changes_to_parent_workshop
    if not self.external_url.blank? and self.workshop.external_url.blank?
      self.workshop.update_attribute(:external_url, self.external_url)
    end
  end
  
end
