class Event < ActiveRecord::Base
  attr_accessible :host, :course, :title, :description, :start_time, :end_time

  belongs_to :host, :class_name => 'User'
  belongs_to :course
  belongs_to :location
  has_and_belongs_to_many :attendees, :class_name => 'User'
  
  validates :host_id, presence: true
  validates :course_id, presence: true
  validates :title, presence: true

  validates_datetime :start_time
  validates_datetime :end_time, :after => :start_time
  
end
