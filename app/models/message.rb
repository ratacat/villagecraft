class Message < ActiveRecord::Base
  attr_accessor :_apropos_uuid

  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'
  belongs_to :apropos, :polymorphic => true

  has_uuid
  acts_as_paranoid
  
  before_validation :find_apropos, :on => :create
  validates :from_user_id, presence: true
  validate :can_send_to_apropos?
  
  protected
  def find_apropos
    unless self._apropos_uuid.blank?
      case self.apropos_type
      when 'Event'
        self.apropos_id = Event.find_by_uuid(self._apropos_uuid).try(:id)
      else
        raise 'Unsupported message type'
      end
    end
  end
  
  def can_send_to_apropos?
    unless self.apropos.blank?
      case self.apropos_type
      when 'Event'
        unless self.apropos.host === self.from_user
          errors.add(:base, "Only the host of a rerun may message attendees")          
        end
      else
        raise 'Unsupported apropos type'
      end
    end
  end
  
  
end
