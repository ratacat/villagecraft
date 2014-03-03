class Message < ActiveRecord::Base
  attr_accessor :_apropos_uuid, :_to_user_uuid

  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'
  belongs_to :apropos, :polymorphic => true

  has_uuid
  acts_as_paranoid
  
  before_validation :find_apropos, :find_to_user, :set_send_at_if_not_set, :on => :create
  validates :from_user_id, presence: true
  validate :can_send_to_apropos?
  
  def apropos=(something)
    write_attribute(:apropos, something)
    self._apropos_uuid = something.try(:uuid)
    self.apropos_type = something.try(:class).try(:to_s)
  end

  protected
  def find_apropos
    apropos_uuid = read_attribute(:_apropos_uuid)
    unless self._apropos_uuid.blank?
      case self.apropos_type
      when 'Workshop'
        self.apropos_id = Workshop.find_by_uuid(self._apropos_uuid).try(:id)
      when 'Event'
        self.apropos_id = Event.find_by_uuid(self._apropos_uuid).try(:id)
      else
        raise 'Unsupported message type'
      end
    end
  end

  def find_to_user
    unless self._to_user_uuid.blank?
      self.to_user = User.find_by_uuid(self._to_user_uuid)
    end
  end
  
  def can_send_to_apropos?
    return(true) unless self.to_user.blank?  # there's no need to check the apropos if a to_user is explicitly specified
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
  
  def set_send_at_if_not_set
    self.send_at ||= Time.now
  end
  
end
