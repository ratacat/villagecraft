class Location < ActiveRecord::Base
  attr_accessible :name, :address
  has_many :venues
  
  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.street = geo.street_address
      obj.city = geo.city
      obj.zip = geo.postal_code
      obj.country = geo.country_code
    end
  end
  after_validation :geocode, :reverse_geocode

end
