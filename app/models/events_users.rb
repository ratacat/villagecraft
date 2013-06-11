class EventsUsers < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :confirmed, :guests
end
