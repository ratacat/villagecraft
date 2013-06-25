require 'has_uuid'
ActiveRecord::Base.send :include, ActiveRecord::Has::UUID
