class Venue < ActiveRecord::Base
  attr_accessible :name, :location, :owner

  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :events
end
