class Venue < ActiveRecord::Base
  attr_accessible :name, :street, :city, :state
  attr_writer :street, :city, :state
  has_uuid(:length => 8)

  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :events
  
  before_validation :find_or_create_location_from_address
  
  validates :name, :presence => true
  validates :owner, :presence => true

  validates :street, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  
  validates :location, :presence => true
  validates_associated :location

  def street
    @street || self.location.try(:street)
  end
  
  def city
    @city || self.location.try(:city)
  end

  def state
    @state || self.location.try(:state_code)
  end
  
  protected
  def find_or_create_location_from_address
    self.location = Location.find_or_create_by_street_and_city_and_state_code(:street => self.street, :city => self.city, :state_code => self.state)
  end
  
end
