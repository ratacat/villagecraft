class Image < ActiveRecord::Base
  has_uuid
  acts_as_paranoid
  include PublicActivity::Common

  belongs_to :user
  belongs_to :apropos, :polymorphic => true
  
  attr_accessible :i, :user, :apropos, :title
  
  has_attached_file :i, 
                    :storage => :s3, :bucket => 'villagecraft', 
                    :s3_headers => {'Expires' => 1.year.from_now.httpdate}, 
                    :s3_credentials => {:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"]},
                    :s3_protocol => :https,
                    :styles => {:xlarge_orig => "800x800>",
                                :larger => "400x400>",  # original aspect ratio
                                :col3 => "270x270#",  # this is Bootstrap col-md-3's width
                                :large_orig => "200x200>",
                                :large => "200x200#", 
                                :medium => "100x100#", 
                                :small => "50x50#", 
                                :thumb => "32x32#" }, 
                    :default_url => "/assets/homunculus_:style.png",
                    :processors => [:thumbnail] #, :paperclip_optimizer]
end
