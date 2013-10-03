class Image < ActiveRecord::Base
  belongs_to :user
  has_uuid
  
  attr_accessible :img, :user
  has_attached_file :img, 
                    :styles => { :large => "200x200>", :medium => "100x100#", :small => "50x50#", :thumb => "32x32#" }, 
                    :default_url => "/assets/homunculus_:style.png"
end
