class Attendance < ActiveRecord::Base
  attr_accessible :confirmed, :guests

  belongs_to :event
  has_one :venue, :through => :event
  
  belongs_to :user
  
  state_machine :initial => :attending do
    event :cancel do
      transition :attending => :canceled
    end

    event :attend do
      transition :canceled => :attending
    end
    
    event :confirm do
      transition :attending => :confirmed
    end
  end
  
end
