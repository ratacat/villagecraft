class Attendance < ActiveRecord::Base
  has_uuid
  acts_as_paranoid
  
  attr_accessible :confirmed, :guests

  belongs_to :event
  has_one :venue, :through => :event
  belongs_to :user
  alias :attendee :user
  
  validates_uniqueness_of :user_id, :scope => :event_id
  validate :event_is_not_external
  
  after_save :touch_to_expire_cached_fragments
  
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
  def event_is_not_external
    if self.event.external?
      errors.add(:event, "is external; you cannot sign up for it through Villagecraft")
    end
  end
  
  def touch_to_expire_cached_fragments
    self.event.touch
    self.event.workshop.touch
  end
end
