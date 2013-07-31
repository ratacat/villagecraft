class Attendance < ActiveRecord::Base
  attr_accessible :confirmed, :guests

  belongs_to :event
  has_one :venue, :through => :event
  
  belongs_to :user
end
