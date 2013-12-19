class User < ActiveRecord::Base
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :token_authenticatable # , :omniauth_providers => [:facebook]
  
  before_save :ensure_authentication_token # whenever a user is saved i,e created or updated it will see that a unique authentication token get created if not already exist

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :remember_me, :name, :city, :state, :profile_image, :location, :has_set_password, :phone, :email_notifications
  attr_writer :city, :state
  has_uuid(:length => 8)

  has_many :workshops, :foreign_key => :host_id, :dependent => :destroy
  has_many :events, :class_name => 'Event', :foreign_key => :host_id
  has_many :owned_venues, :class_name => 'Venue', :foreign_key => :owner_id

  has_many :attendances, :dependent => :destroy
  has_many :venues, :through => :attendances, :uniq => true
  has_many :attends, :through => :attendances, :source => :event, :uniq => true do
    def confirmed
      where("attendances.state = 'confirmed'")
    end
  end

  has_many :reviews, :foreign_key => :author_id, :dependent => :destroy
  belongs_to :location
  has_many :images, :dependent => :destroy
  belongs_to :profile_image, :class_name => 'Image'

  has_many :notifications

  normalize_attributes :name, :email, :address

  before_validation :find_or_create_location_from_address, :normalize_phone

  validates :email, :presence => true
  validates :name, :presence => true
#  validates :city, :presence => true
#  validates :state, :presence => true
#  validates :location, :presence => true
  validates :phone, :presence => true, :uniqueness => true, :format => { :with => /\A\+1[0123456789]{10}\z/, :message => "is not a 10-digit US phone number" }, :allow_blank => true
#  validates_associated :location

  def profile_img_src(size = :medium)
    if self.profile_image.blank?
      User.homunculus_src(size)
    else
      self.profile_image.img.url(size)
    end
  end
  
  def remember_me; true; end

  def User.homunculus_src(size = :medium)
    "/assets/homunculus_#{size}.png"
  end

  def profile_image=(f)
    i = Image.create!(:img => f, :user => self)
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

  def confirmed_attend_at_event?(e)
    self.attends.confirmed.where('"attendances"."event_id"=?', e.id).exists?
  end

  def send_sms(msg)
    if Rails.env.development?
      Rails.logger.info %Q(\v\nVirtual Nexmo SMS (would be sent in production mode):\n :to => "#{self.phone}", :from => "#{NEXMO_NUMBER}", :message => "#{msg}"\n\n)
    else
      User.nexmo.send_message!({:to => self.phone, :from => NEXMO_FROM, :message => msg})
    end
  end

  def User.find_for_facebook_oauth(auth, signed_in_resource=nil)
    unless user = User.where(:auth_provider => auth.provider, :auth_provider_uid => auth.uid).first
      fb_profile_img_uri = URI.parse(auth.info.image)
      fb_profile_img_uri.query = "type=large"
      random_pwd = Devise.friendly_token[0,20]

      location = Location.new_from_address(auth.info.location)

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
      location = Location.new_from_address(session["devise.facebook_data"][:info][:location])
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

  protected
  def find_or_create_location_from_address
    self.location ||= Location.find_or_create_by_city_and_state_code(:city => self.city, :state_code => self.state) unless self.city.blank? or self.state.blank?
  end
  
  def normalize_phone
    unless self.phone.blank?
      normalized_number = self.phone.gsub(/[^0-9]/, '')
      normalized_number.insert(0, (normalized_number =~ /^1\d*/) ? '+' : '+1')      
      self.phone = normalized_number
    end    
  end

end
