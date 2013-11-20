require "has_ordering_through_meetings"

class Workshop < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  include ActiveRecord::Has::OrderingThroughMeetings

  attr_accessible :description, :frequency, :title, :image
  has_uuid(:length => 8)

  belongs_to :image
  belongs_to :host, :class_name => 'User'
  has_many :events # , :dependent => :destroy
  has_many :meetings, :through => :events
  has_many :reviews, :dependent => :destroy
  
  def img_src(size = :medium)
    if self.image.blank?
      Workshop.placeholder_img_src(size)
    else
      self.image.img.url(size)
    end
  end

  def Workshop.placeholder_img_src(size = :medium)
    "/assets/workshop_placeholder_#{size}.png"
  end
  
  def image=(f)
    i = Image.create!(:img => f, :user => self.host)
    self.image_id = i.id
  end

  def last_meeting
    self.meetings.past.order('"meetings"."start_time"').last
  end
  memoize :last_meeting
  
  def next_meeting
    self.meetings.future.order('"meetings"."start_time"').first
  end
  memoize :next_meeting
  
  def next_rerun
    self.events.future.ordered_by_earliest_meeting_start_time.first
  end
  memoize :next_rerun
  
  def last_rerun
    self.events.past.ordered_by_earliest_meeting_start_time.last
  end
  memoize :last_rerun

  def last_scheduled_reruns
    self.events.ordered_by_earliest_meeting_start_time.reverse_order.limit(2)
  end
  memoize :last_scheduled_reruns

end
