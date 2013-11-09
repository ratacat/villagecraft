class Meeting < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :snippet
  belongs_to :event
  belongs_to :venue
end
