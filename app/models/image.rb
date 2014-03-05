class Image < ActiveRecord::Base
  belongs_to :user
  has_uuid
  acts_as_paranoid
  
  attr_accessible :i, :user
  
  AWS_ACCESS_KEY = 'AKIAII3AMFUMVNSGTVDA'
  AWS_SECRET_KEY = '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'
  has_attached_file :i, 
                    :storage => :s3, :bucket => 'villagecraft', :s3_headers => {'Expires' => 1.year.from_now.httpdate}, :s3_credentials => {:access_key_id => AWS_ACCESS_KEY, :secret_access_key => AWS_SECRET_KEY},
                    :styles => {:larger => "400x400>",  # original aspect ratio
                                :xlarge => "270x270#",  # this is Bootstrap span3's width
                                :large_orig => "200x200>",
                                :large => "200x200#", 
                                :medium => "100x100#", 
                                :small => "50x50#", 
                                :thumb => "32x32#" }, 
                    :default_url => "/assets/homunculus_:style.png"
end
