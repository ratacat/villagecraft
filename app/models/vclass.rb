class Vclass < ActiveRecord::Base
  belongs_to :admin, :class_name => 'User'
  has_many :reviews
  has_many :courses
  # attr_accessible :title, :body
end
