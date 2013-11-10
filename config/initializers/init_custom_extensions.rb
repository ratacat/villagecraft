require 'has_uuid'
ActiveRecord::Base.send :include, ActiveRecord::Has::UUID

require 'has_start_and_end_time'
ActiveRecord::Base.send :include, ActiveRecord::Has::StartAndEndTime
