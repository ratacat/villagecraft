class Message < ActiveRecord::Base
  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'
  belongs_to :apropos, :polymorphic => true

  has_uuid
  acts_as_paranoid  
end
