class Review < ActiveRecord::Base
  belongs_to :event
#  belongs_to :prior_review, :class_name => 'Review'
  belongs_to :author, :class_name => 'User'
  attr_accessible :body
end
