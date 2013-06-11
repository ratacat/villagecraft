class Location < ActiveRecord::Base
  belongs_to :owner
  attr_accessible :city, :name, :state, :street, :zip
end
