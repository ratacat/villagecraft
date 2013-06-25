class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name_first, :name_last, :city, :state
  attr_writer :city, :state
  has_uuid(:length => 8)

  has_many :hostings, :class_name => 'Event', :foreign_key => :host_id
  has_and_belongs_to_many :attends, :class_name => 'Event', :uniq => true
  has_many :events_users
  has_many :confirmed_attends, :through => :events_users, 
           :class_name => "Event", 
           :source => :event, 
           :conditions => ['events_users.confirmed = ?',true]
  has_many :reviews
  belongs_to :location
  
  strip_attributes :only => [:name_first, :name_last, :email, :address]
  
  before_validation :find_or_create_location_from_address
  
  validates :name_first, :presence => true
  validates :name_last, :presence => true
  validates :location, :presence => true
  validates_associated :location
  
  def name
    "#{self.name_first} #{self.name_last}"
  end
  
  # FIXME: stub
  def profile_img_src(size = :thumb)
    "/assets/homunculus.png"
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
  
  protected
  def find_or_create_location_from_address
    self.location = Location.find_or_create_by_city_and_state_code(:city => self.city, :state_code => self.state)
  end
  
end
