class Comment < ActiveRecord::Base
  attr_accessible :body, :event_id, :user_id
  belongs_to :event
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable
  default_scope :order => 'created_at ASC'

  def event
    return @event if defined?(@event)
    @event = commentable.is_a?(Event) ? commentable : commentable.event
  end
end
