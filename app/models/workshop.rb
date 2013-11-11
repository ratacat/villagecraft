class Workshop < ActiveRecord::Base
  attr_accessible :description, :frequency, :title, :host
  has_uuid(:length => 8)
  has_start_and_end_time

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

end
