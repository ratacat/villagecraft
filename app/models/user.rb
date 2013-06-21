class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name_first, :name_last

  has_many :hostings, :class_name => 'Event', :foreign_key => :host_id
  has_and_belongs_to_many :attends, :class_name => 'Event', :uniq => true
  has_many :events_users
  has_many :confirmed_attends, :through => :events_users, 
           :class_name => "Event", 
           :source => :event, 
           :conditions => ['events_users.confirmed = ?',true]
  has_many :reviews
  
  strip_attributes :only => [:name_first, :name_last, :email]
  
  validates :name_first, :presence => true
  validates :name_last, :presence => true
  
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

  # FIXME: stub
  def city
    "Berkeley, CA"
  end
  
end
