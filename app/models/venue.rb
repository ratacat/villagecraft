class Venue < ActiveRecord::Base
  attr_accessible :name, :street, :city, :state_code, :address
  attr_writer :street, :city, :state_code, :address
  has_uuid(:length => 8)
  acts_as_paranoid

  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :meetings
  
  before_validation :create_location
  
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
  def create_location
    self.location = Location.create(:address => self.address, :street => self.street, :city => self.city, :state_code => self.state_code)
  end
  
end
