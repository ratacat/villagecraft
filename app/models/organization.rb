class Organization < ActiveRecord::Base
  attr_accessible :name
  has_many :event_organizations
  has_many :events, through: :event_organizations

  validates :name , presence: true
end
