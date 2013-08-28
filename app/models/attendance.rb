class Attendance < ActiveRecord::Base
  attr_accessible :confirmed, :guests

  belongs_to :event
  has_one :venue, :through => :event
  belongs_to :user
  
  validates_uniqueness_of :user_id, :scope => :event_id
  
  state_machine :initial => :applied do
=begin Instead of deleting attendance records, possible add a canceled state like this    
    event :cancel do
      transition [:applied, :attending] => :canceled
    end
=end
    event :accept do
      transition :applied => :attending
    end
    
    event :confirm do
      transition :attending => :confirmed
    end
  end
  
end
