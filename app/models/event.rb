class Event < ActiveRecord::Base
  attr_accessible :description

  belongs_to :user
  validates :user_id, presence: true
end
