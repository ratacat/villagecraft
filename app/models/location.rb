class Location < ActiveRecord::Base
  has_many :venues
  attr_accessible :city, :name, :state, :street, :zip
end
