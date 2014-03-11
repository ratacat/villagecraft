class Message < ActiveRecord::Base
  attr_writer :_apropos_uuid, :_to_user_uuid
  attr_accessible :_apropos_uuid, :_to_user_uuid, :apropos_type, :subject, :body, :apropos, :to_user
  
  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'
  belongs_to :apropos, :polymorphic => true

  has_uuid
  acts_as_paranoid
  
  before_validation :find_apropos, :find_to_user, :set_send_at_if_not_set, :on => :create
  validates :from_user_id, presence: true
  validate :can_send_to_apropos?, :has_to_user_or_apropos?

  def _apropos_uuid
    @_apropos_uuid || self.apropos.try(:uuid)
  end

  def _to_user_uuid
    @_to_user_uuid || self.to_user.try(:uuid)
  end

  def apropos_type
    read_attribute(:apropos_type) || self.apropos.try(:class).try(:to_s)
  end

  def deliver
    if self.to_user
      UserMailer.message_email(self, self.to_user.email).deliver
    elsif self.apropos
      case self.apropos
      when Event
        self.apropos.attendees.find_each do |attendee|
          UserMailer.message_email(self, attendee.email).deliver          
        end
      else
        raise "Don't know how to deliver a message apropos of a: #{self.apropos.class} (#{self.id})"
      end
    else
      raise "Cannot deliver a message with no apropos or to user (#{self.id})"
    end
    self.update_attribute(:sent_at, Time.now)
  end

  protected
  def find_apropos
    unless @_apropos_uuid.blank?
      case self.apropos_type
      when 'Workshop'
        self.apropos_id = Workshop.find_by_uuid(@_apropos_uuid).try(:id)
      when 'Event'
        self.apropos_id = Event.find_by_uuid(@_apropos_uuid).try(:id)
      else
        raise "Unsupported message type: #{self.apropos_type}"
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
        raise "Unsupported apropos type"
      end
    end
  end
  
  def has_to_user_or_apropos?
    unless self.apropos or self.to_user
      errors.add(:base, "Must have a to_user or an apropos.")          
    end
  end
  
  def set_send_at_if_not_set
    self.send_at ||= Time.now
  end
  
end
