class Meeting < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :snippet
  has_uuid(:length => 8)
  
  belongs_to :event
  belongs_to :venue
end
