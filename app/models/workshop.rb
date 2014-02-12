class Workshop < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  include ActiveModel::ForbiddenAttributesProtection
  include PublicActivity::Model
  tracked :owner => Proc.new{ |controller, model| controller.try(:current_user) },
          :on => {:create  => proc {|model, controller| controller  },
                  :update  => proc {|model, controller| controller  },
                  :destroy => proc {|model, controller| controller  }}
  has_uuid(:length => 8)
  acts_as_paranoid

  belongs_to :image
  belongs_to :host, :class_name => 'User'
  has_many :events, :dependent => :destroy, :conditions => {:deleted_at => nil}
  has_many :meetings, :through => :events
  has_many :first_meetings, :through => :events
  has_many :locations, :through => :events
  has_many :reviews, :dependent => :destroy, :conditions => {:deleted_at => nil}
  
  validates :title, presence: true, uniqueness: {:scope => :host_id, :message => 'you already have a workshop with this name; edit it and/or schedule a new meeting for it'}
  validates :host_id, presence: true
  validates :external_url, :url => {:if => lambda {|workshop| workshop.external?}}, :allow_blank => true
  
  belongs_to :venue
  has_one :location, :through => :venue
  
  after_update :propagate_changes_to_future_events
  
  def Workshop.by_distance_from(l)
    # get spheroid distance in meters
    dist_q = %{ST_Distance_Spheroid( #{Location.quoted_table_column(:point)}, ST_GeomFromText('POINT(#{l.longitude} #{l.latitude})', 4326), 'SPHEROID["WGS 84",6378137,298.257223563]')};
    joins(:location).select(%{"workshops".*, (#{dist_q}) AS dist}).order(:dist)
  end
  
  def Workshop.first_meeting_in_the_future
    joins(:first_meetings).where(%Q(#{Meeting.quoted_table_column(:end_time)} > ?), Time.now)
  end
  
  def to_param
    "#{self.uuid} #{self.title}}".parameterize
  end

  def Workshop.find_by_seod_uuid!(id)
    Workshop.find_by_uuid!(id.split('-').first)
  end

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
  
  def ongoing_or_upcoming_reruns
    self.events.where_first_meeting_ends_in_future
  end
  memoize :ongoing_or_upcoming_reruns

  def upcoming_reruns
    self.events.where_first_meeting_starts_in_future
  end
  memoize :upcoming_reruns
  
  def ongoing_or_next_rerun
    self.ongoing_or_upcoming_reruns.first
  end
  memoize :ongoing_or_next_rerun

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
  
  def cache_key(context = nil)
    if context
      "workshop-#{context}-#{self.uuid}-#{self.updated_at.to_i}"
    else
      "workshop-#{self.uuid}-#{self.updated_at.to_i}"
    end
  end
  
  protected
  
  def propagate_changes_to_future_events
    if self.title_changed? or self.description_changed?
      self.events.where_first_meeting_starts_in_future.readonly(false).each do |event|
        event.update_attributes(:title => self.title, :description => self.description)
      end      
    end
  end

end
