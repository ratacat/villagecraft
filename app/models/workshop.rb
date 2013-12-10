class Workshop < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  include PublicActivity::Model
  tracked :owner => Proc.new{ |controller, model| controller.current_user },
          :on => {:create  => proc {|model, controller| controller  },
                  :update  => proc {|model, controller| controller  },
                  :destroy => proc {|model, controller| controller  }}
    
  attr_accessible :description, :frequency, :title, :image
  has_uuid(:length => 8)

  belongs_to :image
  belongs_to :host, :class_name => 'User'
  has_many :events # , :dependent => :destroy
  has_many :meetings, :through => :events
  has_many :first_meetings, :through => :events
  has_many :reviews, :dependent => :destroy
  
  validates :title, presence: true
  
  after_update :propagate_changes_to_future_events
  
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
  
  def upcoming_reruns
    self.events.where_first_meeting_starts_in_future
  end
  memoize :upcoming_reruns
  
  def next_rerun
    self.upcoming_reruns.first
  end
  memoize :next_rerun
  
  def last_rerun
    self.events.where_first_meeting_starts_in_past.first
  end
  memoize :last_rerun

  def last_scheduled_reruns
    self.events.ordered_by_earliest_meeting_start_time.reverse_order.limit(2)
  end
  memoize :last_scheduled_reruns
  
  protected
  
  def propagate_changes_to_future_events
    self.events.where_first_meeting_starts_in_future.readonly(false).each do |event|
      event.update_attributes(:title => self.title, :description => self.description)
    end
  end

end
