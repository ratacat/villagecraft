class EventsUser < ActiveRecord::Base
  attr_accessible :user, :event, :hosting, :as => :system
  
  belongs_to :user
  belongs_to :event
  
  validates :user, presence: true
  validates :event, presence: true
  
end
