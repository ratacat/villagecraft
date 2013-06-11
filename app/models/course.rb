class Course < ActiveRecord::Base
  belongs_to :vclass
  has_many :events
  # attr_accessible :title, :body
end
