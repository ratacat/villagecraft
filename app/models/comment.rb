class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable
  default_scope :order => 'created_at ASC'
  has_uuid

  # def event
  #   return @event if defined?(@event)
  #   @event = commentable.is_a?(Event) ? commentable : commentable.event
  # end
  
end
