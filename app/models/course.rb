class Course < ActiveRecord::Base
  attr_accessible :title, :vclass

  belongs_to :vclass
  has_many :events, :dependent => :destroy
  
  validates :vclass_id, presence: true
  validates :title, presence: true
  
  before_validation :set_default_values, :on => :create
  
  protected
  def set_default_values
    self.title ||= self.vclass.try(:title)
  end
end
