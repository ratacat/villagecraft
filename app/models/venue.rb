class Venue < ActiveRecord::Base
  has_uuid(:length => 8)
  acts_as_paranoid

  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :meetings
  
  validates :location, :presence => true
  validates_associated :location
  
  def public?
    false
  end
  
  def location=(params)
    self.create_location(params)
  end

  def address=(a)
    self.create_location(address: a)
  end
  
end
