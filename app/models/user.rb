class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable # :omniauth_providers => [:facebook]
  
  # token_authenticatable was removed from devise 3; this is Jose Valim's suggestion for adding it back in in a secure way (see: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6)
  before_save :ensure_authentication_token
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
  after_create :welcome_the_new_user
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :remember_me, :name, :city, :state, :profile_image, :location, :has_set_password, :phone, :email_notifications, :stripe_token
  attr_writer :city, :state
  has_uuid(:length => 8)

  has_many :workshops, :foreign_key => :host_id, :dependent => :destroy, :conditions => {:deleted_at => nil}
  has_many :events, :class_name => 'Event', :foreign_key => :host_id
  has_many :owned_venues, :class_name => 'Venue', :foreign_key => :owner_id, :dependent => :destroy, :conditions => {:deleted_at => nil}

  has_many :attendances, :dependent => :destroy, :conditions => {:deleted_at => nil}
  has_many :venues, :through => :attendances, :uniq => true
  has_many :attends, :through => :attendances, :source => :event, :uniq => true do
    def confirmed
      where("attendances.state = 'confirmed'")
    end
    def past
      where_first_meeting_starts_in_past
      where(%Q(#{Event.quoted_table_name}."end_time" < ?), t )
    end
  end

  # locations this user has appeared in
  has_many :sightings
  has_many :locations, :through => :sightings
  def last_sighting
    self.sightings.order(:updated_at).reverse_order.first
  end

  has_many :reviews, :foreign_key => :author_id, :dependent => :destroy, :conditions => {:deleted_at => nil}
  belongs_to :location
  has_many :images, :dependent => :destroy, :conditions => {:deleted_at => nil}
  belongs_to :profile_image, :class_name => 'Image'

  has_many :notifications

  has_many :rating

  normalize_attributes :name, :email, :address

  before_validation :find_or_create_location_from_address, :normalize_phone, :create_bogus_email_for_external_users
  after_save :touch_dependant_workshops_to_expire_their_cached_fragments

  validates :email, :presence => true
  validates :name, :presence => true
#  validates :city, :presence => true
#  validates :state, :presence => true
#  validates :location, :presence => true
  validates :phone, :uniqueness => true, :format => { :with => /\A\+1[0123456789]{10}\z/, :message => "is not a 10-digit US phone number" }, :allow_blank => true
  DISTANCE_UNITS = [['miles', 'mi'], ['kilometers', 'km']]
  validates :preferred_distance_units, :inclusion => {:in => ['mi', 'km'], :message => "must be miles (mi) or kilometers (km)" }
  
#  validates_associated :location
  

  def profile_img_src(size = :medium)
    if self.profile_image.blank?
      User.homunculus_src(size)
    else
      self.profile_image.i.url(size)
    end
  end
  
  def remember_me; true; end

  def User.homunculus_src(size = :medium)
    "/assets/homunculus_#{size}.png"
  end

  def profile_image=(f)
    i = Image.create!(:i => f, :user => self)
    self.profile_image_id = i.id
  end

  def is_host_of?(obj)
    obj.respond_to?(:host) and (self == obj.host)
  end

  # straightforward rate of attendance
  # TODO: compute a "velocity" 0-100 that weights recent attendance more highly
  def velocity
    if self.attends.completed.count > 0
      self.attends.confirmed.completed.count.to_f / self.attends.completed.count.to_f
    else
      0
    end
  end

  def possessable_name(options={})
    defaults = {
      :full => false
    }
    options.reverse_merge!(defaults)
    if self.external? or options[:full]
      self.name
    else
      self.first_name
    end
  end
  
  def first_name
    self.name.split[0]
  end

  def last_name
    self.name.split.pop
  end
  
  def title
    self.name
  end
  
  def first_name_plus_last_initial
    "#{self.first_name} #{self.last_name[0,1]}."
  end

  def city
    @city || self.location.try(:city)
  end

  def state
    @state || self.location.try(:state_code)
  end

  def time_zone
    self.try(:location).try(:time_zone) || "America/Los_Angeles"
  end

  def distance_to(o)
    l = o.is_a?(Location) ? o : o.location
    Geocoder::Calculations.distance_between(self.location, l).round(2)
  end

  # FIXME: stub
  def rating_as_host
    generator = Random.new # You need to instance it
    generator.rand(1.0..10.0).round(1)
  end

  def attending_event?(e)
    self.attends.where('"attendances"."event_id"=?', e.id).exists?
  end

  def attends_of_workshop(workshop)
    self.attends.joins(:meetings).joins(:workshop).where(%Q(#{Workshop.quoted_table_name}."uuid" = ?), workshop.uuid)
  end

  def attending_workshop?(workshop)
    self.attends_of_workshop(workshop).where(%Q(#{Meeting.quoted_table_name}."end_time" > ?), Time.now).count > 0
  end
  
  def attended_workshop?(workshop)
    self.attends_of_workshop(workshop).where(%Q(#{Meeting.quoted_table_name}."end_time" < ?), Time.now).count > 0
  end
  
  def reviewed_workshop?(workshop)
    self.reviews.where(%Q(#{Review.quoted_table_name}."apropos_id" = ? OR #{Review.quoted_table_name}."apropos_id" IN (?)), workshop.id, workshop.events).count > 0
  end
  
  def can_review?(workshop)
    (self.attended_workshop?(workshop) or workshop.has_any_non_rsvp_event?) and not self.reviewed_workshop?(workshop)
  end

  def confirmed_attend_at_event?(e)
    self.attends.confirmed.where('"attendances"."event_id"=?', e.id).exists?
  end
  
  def privileges
    ret = []
    ret << 'host' if self.host?
    ret << 'admin' if self.admin?
    ret << 'external' if self.external?
    ret
  end

  # route the notification appropriately, depending on the user's settings
  def notify(activity)
    case activity.key
    when 'event.sms', 'workshop.sms', 'meeting.reminder'
      Notification.create(:user => self, :activity => activity, :email_me => self.email_short_messages, :sms_me => (self.sms_short_messages and not self.phone.blank?))
    else
      Notification.create(:user => self, :activity => activity, :email_me => self.email_notifications)
    end
  end

  def send_sms(msg)
    if Rails.env.development?
      Rails.logger.info %Q(\v\nVirtual Nexmo SMS (would be sent in production mode):\n :to => "#{self.phone}", :from => "#{NEXMO_NUMBER}", :message => "#{msg}"\n\n)
    else
      User.nexmo.send_message({:to => self.phone, :from => NEXMO_NUMBER, :text => msg})
    end
  end

  def fb_authenticated?
    self.auth_provider === 'facebook'
  end

  def User.find_for_facebook_oauth(auth, signed_in_resource=nil)
    unless user = User.where(:auth_provider => auth.provider, :auth_provider_uid => auth.uid).first
      fb_profile_img_uri = URI.parse(auth.info.image.gsub(/^http:/, 'https:'))
      fb_profile_img_uri.query = "type=large"
      random_pwd = Devise.friendly_token[0,20]

      location = Location.create(:address => auth.info.location)

      user = User.find_by_email(auth.info.email) ||
             User.new(:email => auth.info.email,
                      :name => "#{auth.info.first_name} #{auth.info.last_name}",
                      :city => location.city,
                      :state => location.state_code,
                      :profile_image => fb_profile_img_uri,
                      :password => random_pwd,
                      :password_confirmation => random_pwd,
                      :has_set_password => false
                      )
      user.profile_image ||= fb_profile_img_uri
      user.auth_provider = auth.provider
      user.auth_provider_uid = auth.uid
    end
    user
  end

  def User.new_with_session(params, session)
    if session["devise.facebook_data"]
      fb_params = session["devise.facebook_data"][:info].slice(:email, :first_name, :last_name)
      location = Location.create(:address => session["devise.facebook_data"][:info][:location])
      fb_params[:city] = location.city
      fb_params[:state] = location.state_code
      new(fb_params, without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def User.nexmo
    @@nexmo ||= Nexmo::Client.new(NEXMO_API_KEY, NEXMO_API_SECRET)
  end
  
  def has_fake_email?
    m = Mail::Address.new(self.email)
    m.domain === "me.fake"
  end

  # Returns all past events that the user signed up for
  def get_all_attended_events
    events_id = Attendance.where(:user_id => self).map{ |attendence| attendence.event.id}
    Event.where(:id => events_id).where_first_meeting_starts_in_past
  end

  def get_last_attended_event_by_workshop(workshop)
    events_id = Attendance.where(:user_id => self).map{ |attendence| attendence.event.id}
    Event.where(:id => events_id, :workshop_id => workshop).where_first_meeting_starts_in_past.first
  end

  protected
  def find_or_create_location_from_address
    self.location = Location.find_or_create_by_city_and_state_code(:city => self.city, :state_code => self.state) unless self.city.blank? or self.state.blank?
  end
  
  def welcome_the_new_user
    UserMailer.welcome_email(self).deliver unless self.external?
  end
  
  def normalize_phone
    unless self.phone.blank?
      normalized_number = self.phone.gsub(/[^0-9]/, '')
      normalized_number.insert(0, (normalized_number =~ /^1\d*/) ? '+' : '+1')      
      self.phone = normalized_number
    end    
  end
  
  def create_bogus_email_for_external_users
    if self.external?
      self.email = "#{self.uuid}@me.fake" if self.email.blank?
    end
  end

  private
  # token_authenticatable was removed from devise 3; this is Jose Valim's suggestion for adding it back in in a secure way (see: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6)
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
  
  def touch_dependant_workshops_to_expire_their_cached_fragments
    self.workshops.update_all(updated_at: Time.now)
  end

end
