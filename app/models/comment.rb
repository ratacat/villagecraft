class Comment < ActiveRecord::Base
  attr_accessible :body, :event_id, :user_id
  belongs_to :event
  belongs_to :user
  has_many :comments
end
