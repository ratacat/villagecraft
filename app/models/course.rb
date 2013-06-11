class Course < ActiveRecord::Base
  belongs_to :vclass
  has_many :events
  # attr_accessible :title, :body
  
  validates :vclass_id, presence: true
  validates :title, presence: true
end
