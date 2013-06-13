class Event < ActiveRecord::Base
  attr_accessible :host, :course, :title, :description, :date, :start_time_time, :end_time_time
  attr_accessor :date, :start_time_time, :end_time_time

  belongs_to :host, :class_name => 'User'
  belongs_to :course
  belongs_to :location
  has_and_belongs_to_many :attendees, :class_name => 'User'
  
  before_validation :derive_times, :create_course_and_vclass_if_missing
  
  validates :host_id, presence: true
  validates :course_id, presence: true
  validates :title, presence: true

  validates_datetime :start_time
  validates_datetime :end_time, :after => :start_time
  
  validates_time :start_time_time
  validates_time :end_time_time, :after => :start_time_time
  
  
  def date
   @date || self.start_time.try(:to_date)
  end

  def start_time_time
   @start_time_time || self.start_time.try(:to_time)
  end

  def end_time_time
   @end_time_time || self.end_time.try(:to_time)
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
