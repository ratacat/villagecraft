class Vclass < ActiveRecord::Base
  attr_accessible :title, :admin

  belongs_to :admin, :class_name => 'User'
  has_many :reviews
  has_many :courses
  
  validates :admin_id, presence: true
  validates :title, presence: true
  
end
