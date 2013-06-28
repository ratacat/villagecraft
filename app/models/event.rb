class Event < ActiveRecord::Base
  attr_accessible :host, :course, :title, :description, :date, :start_time_time, :end_time_time, :short_title, :min_attendees, :max_attendees
  attr_accessor :date, :start_time_time, :end_time_time
  has_uuid(:length => 8)

  belongs_to :host, :class_name => 'User'
  belongs_to :course
  belongs_to :venue
  has_one :location, :through => :venue
  has_and_belongs_to_many :attendees, :class_name => 'User', :uniq => true
  
  scope :completed, lambda { where('"events"."end_time" < ?', Time.now ) }
  scope :future, lambda { where('"events"."end_time" > ?', Time.now ) }

  before_validation :derive_times, :create_course_and_vclass_if_missing
  strip_attributes :only => [:title, :short_title, :description]
  
  validates :host_id, presence: true
  validates :course_id, presence: true
  validates :title, presence: true
  validates :short_title, :length => { :minimum => 1, :maximum => 2, :message => "must contain only one or two words", :tokenizer => lambda {|s| s.split }}
  validates :short_title, presence: true
  validates :min_attendees, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => :max_attendees, :message => "must be less than or equal to max attendees" }, :presence => true
  validates :max_attendees, :numericality => { :greater_than => 0, :greater_than_or_equal_to => :min_attendees, :message => "must be greater than or equal to min attendees" }, :presence => true

  validates_datetime :start_time
  validates_datetime :end_time, :after => :start_time

  validates :date, :presence => true
  validates_date :date
  
  validates :start_time_time, :presence => true
  validates_time :start_time_time
  
  validates :end_time_time, :presence => true
  validates_time :end_time_time, :after => :start_time_time
  
  validates :description, :presence => true
  
  def date
   @date || self.start_time.try(:to_date)
  end

  def start_time_time
   @start_time_time || self.start_time.try(:to_time)
  end

  def end_time_time
   @end_time_time || self.end_time.try(:to_time)
  end
  
  def occurred? 
    self.start_time - Time.now < 0
  end

  protected

  def derive_times
    self.start_time ||= Timeliness.parse("#{self.date} #{self.start_time_time}") unless self.date.blank? or self.start_time_time.blank?
    self.end_time ||= Timeliness.parse("#{self.date} #{self.end_time_time}") unless self.date.blank? or self.end_time_time.blank?
    
    self.start_time_time = Timeliness.parse(self.start_time_time)
    self.end_time_time = Timeliness.parse(self.end_time_time)
  end
  
  def create_course_and_vclass_if_missing
    if self.course.blank?
      vclass = Vclass.create(:title => self.title, :admin => self.host)
      self.course = Course.create(:title => self.title, :vclass => vclass)
    end
  end
end
