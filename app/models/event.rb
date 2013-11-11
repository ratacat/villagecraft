class Event < ActiveRecord::Base
  include PublicActivity::Common
  attr_accessible :host, :title, :description, :start_time_date, :end_time_date, :start_time_time, :end_time_time, :short_title, :min_attendees, :max_attendees, :image
  attr_accessor :start_time_date, :end_time_date, :start_time_time, :end_time_time
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
  
  scope :completed, lambda { where(%{"events"."end_time" < ?}, Time.now ) }
  scope :ordered_by_earliest_start_time, lambda { joins('LEFT JOIN "meetings" ON "meetings"."event_id" = "events"."id"').select('"events".*, min("meetings"."start_time") as earliest_start_time').group('"events"."id"').order('earliest_start_time')}
  scope :ordered_by_latest_end_time, lambda { joins('LEFT JOIN "meetings" ON "meetings"."event_id" = "events"."id"').select('"events".*, max("meetings"."end_time") as latest_end_time').group('"events"."id"').order('latest_end_time').reverse_order}
  scope :future, lambda { where('"meetings"."start_time" > ?', Time.now) }
  scope :past, lambda { where('"meetings"."start_time" < ?', Time.now) }
  
  after_initialize :generate_secret_if_missing
  before_validation :derive_times
  normalize_attributes :title, :short_title, :description, :start_time_date, :end_time_date, :start_time_time, :end_time_time
  
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
    self.start_time - Time.now < 0
  end

  def slots_left
    self.max_attendees - self.attendances.count # self.attendances.with_state(:attending).count
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
  
  def img_src(size = :medium)
    if self.image.blank?
      Event.placeholder_src(size)
    else
      self.image.img.url(size)
    end
  end
  
  def Event.placeholder_src(size = :medium)
#    "/assets/event_placeholder_#{size}.png"
    "/assets/event_placeholder.png"
  end
  
  def image=(f)
    i = Image.create!(:img => f, :user => self.host)
    self.image_id = i.id
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
