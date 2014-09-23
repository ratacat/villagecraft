class Comment < ActiveRecord::Base
  attr_accessible :body, :commentable_id, :commentable_type, :user_id
  # belongs_to :event
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable
end
