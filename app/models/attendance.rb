class Attendance < ActiveRecord::Base
  has_uuid
  attr_accessible :confirmed, :guests

  belongs_to :event
  has_one :venue, :through => :event
  belongs_to :user
  
  validates_uniqueness_of :user_id, :scope => :event_id
  
  after_create :send_confirmation_email
  
  state_machine :initial => :interested do
=begin Instead of deleting attendance records, possible add a canceled state like this    
    event :cancel do
      transition [:interested, :attending] => :canceled
    end
=end
    event :accept do
      transition :interested => :attending
    end
    
    event :confirm do
      transition :attending => :confirmed
    end
  end
  
  protected
  def send_confirmation_email
    UserMailer.confirm_attendance(self).deliver
  end
  
end
