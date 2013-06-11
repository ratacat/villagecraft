class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  # attr_accessible :title, :body

  has_many :events, dependent: :destroy
  has_many :hostings, :class_name => 'Event', :foreign_key => :host_id
  has_and_belongs_to_many :attends, :class_name => 'Event'
  has_many :reviews
end
