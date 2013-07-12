class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :city, :state, :profile_image, :auth_provider, :auth_provider_uid
  attr_writer :city, :state
  has_uuid(:length => 8)

  has_many :hostings, :class_name => 'Event', :foreign_key => :host_id
  has_many :venues, :class_name => 'Venue', :foreign_key => :owner_id
  has_many :attendances
  has_many :attends, :through => :attendances, :source => :event, :uniq => true do
    def confirmed
      where("attendances.confirmed = ?", true)
    end
  end
    
  has_many :confirmed_attends, :through => :events_users, 
           :class_name => "Event", 
           :source => :event, 
           :conditions => ['events_users.confirmed = ?',true]
           
  has_many :reviews
  belongs_to :location
  has_many :images, :dependent => :destroy
  belongs_to :profile_image, :class_name => 'Image'
  
  normalize_attributes :first_name, :last_name, :email, :address
  
  before_validation :find_or_create_location_from_address
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :location, :presence => true
  validates_associated :location
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def profile_img_src(size = :medium)
    if self.profile_image.blank?
      "/assets/homunculus.png"
    else
      self.profile_image.img.url(size)
    end
  end
  
  def profile_image=(f)
    i = Image.create!(:img => f, :user => self)
    self.profile_image_id = i.id
  end  
  
  # FIXME: stub
  def velocity
    100
  end

  def city
    @city || self.location.try(:city)
  end

  def state
    @state || self.location.try(:state_code)
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
    self.attends.where("'attendances'.'event_id'=?", e.id).exists?
  end

  def confirmed_attend_at_event?(e)
    self.attends.confirmed.where("'attendances'.'event_id'=?", e.id).exists?
  end
  
  def User.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:auth_provider => auth.provider, :auth_provider_uid => auth.uid).first
    unless user
      user = User.create(:first_name => auth.extra.raw_info.first_name,
                         :last_name => auth.extra.raw_info.last_name,
                         :auth_provider => auth.provider,
                         :auth_provider_uid => auth.uid,
                         :email => auth.info.email,
                         :password => Devise.friendly_token[0,20]
                         )
    end
    user
  end

  def User.new_with_session(params, session)
    if session["devise.facebook_data"]
      new(session["devise.facebook_data"][:info].slice(:email, :first_name, :last_name), without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end    
  end
  
  protected
  def find_or_create_location_from_address
    self.location = Location.find_or_create_by_city_and_state_code(:city => self.city, :state_code => self.state) unless self.city.blank? or self.state.blank?
  end
  
end
