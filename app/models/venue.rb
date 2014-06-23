class Venue < ActiveRecord::Base
  has_uuid(:length => 8)
  acts_as_paranoid
  attr_reader :address
  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  has_many :meetings
  has_many :events
  
  validates :location, :presence => true
  validates_associated :location
  
  def public?
    false
  end
  
  def location=(params)
    self.build_location(params)
  end

  def address=(a)
    self.build_location(address: a)
  end

  def address
    if self.location.present?
      self.location.address
    else
      nil
    end
  end

  def attributes
    super.merge({'address' => address})
  end

end
