class Notification < ActiveRecord::Base
  attr_accessible :user, :activity
  has_uuid(:length => 8)
  
  belongs_to :user
  belongs_to :activity, :class_name => 'PublicActivity::Activity'
  attr_accessible :seen, :sent
end
