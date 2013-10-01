class Vclass < ActiveRecord::Base
  attr_accessible :title, :admin

  belongs_to :admin, :class_name => 'User'
  belongs_to :image, :class_name => 'Image'

  has_many :reviews, :dependent => :destroy
  has_many :courses, :dependent => :destroy
  
  validates :admin_id, presence: true
  validates :title, presence: true
  
  
  
end
