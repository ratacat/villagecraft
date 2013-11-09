class Workshop < ActiveRecord::Base
  attr_accessible :description, :frequency, :title

  belongs_to :image
  belongs_to :host, :class_name => 'User'
  has_many :events, :dependent => :destroy
  has_many :reviews, :dependent => :destroy
end
