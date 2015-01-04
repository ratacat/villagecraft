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
  
  def display_name
    if self.name.blank?
      self.location.street
    elsif self.location.blank?
      self.name
    else
      "#{self.name} (#{self.location.street})"
    end
  end
  
end
