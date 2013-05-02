class Event < ActiveRecord::Base
  attr_accessible :description, :title, :date
  before_save :adjust_date

  def adjust_date
  	#its not even making it into the model
  	#Rails.logger.info ("debug:" + self.inspect)
  	#DateTime.strptime(self,"%Y-%m-%d")
  end

  belongs_to :user
  validates :user_id, presence: true
end
