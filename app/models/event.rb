class Event < ActiveRecord::Base
  attr_accessible :description, :title, :date

  belongs_to :user
  validates :user_id, presence: true
end
