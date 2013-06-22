class Location < ActiveRecord::Base
  attr_accessible :name, :address
  has_many :venues
  
  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.street = geo.street_address
      obj.city = geo.city
      obj.state = geo.state
      obj.state_code = geo.state_code
      obj.zip = geo.postal_code
      obj.country = geo.country_code
    end
  end
  before_validation :geocode, :reverse_geocode
  
  validates :country, :inclusion => { :in => %w(US), :message => "is not the United States" }
  
end
