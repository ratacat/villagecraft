class Venue < ActiveRecord::Base
  attr_accessible :name, :street, :city, :state_code, :address
  attr_writer :street, :city, :state_code, :address
  has_uuid(:length => 8)

  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :events, :dependent => :destroy
  has_many :courses, :through => :events
  has_many :vclasses, :through => :events
  
  before_validation :find_or_create_location_from_address
  
  validates :name, :presence => true
  validates :owner, :presence => true

  validates :street, :presence => true
  validates :city, :presence => true
  validates :state_code, :presence => true
  
  validates :location, :presence => true
  validates_associated :location

  def street
    @street || self.location.try(:street)
  end
  
  def city
    @city || self.location.try(:city)
  end

  def state_code
    @state_code || self.location.try(:state_code)
  end
  
  def address
    @address || self.location.try(:address)
  end
  
  def public?
    false
  end
  
  protected
  def find_or_create_location_from_address
    if self.address
      self.location = Location.new_from_address(self.address)
    else
      self.location = Location.find_or_create_by_street_and_city_and_state_code(:street => self.street, :city => self.city, :state_code => self.state_code)
    end
  end
  
end
