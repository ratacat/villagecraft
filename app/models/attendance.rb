class Attendance < ActiveRecord::Base
  attr_accessible :confirmed, :guests

  belongs_to :event
  belongs_to :user
end
