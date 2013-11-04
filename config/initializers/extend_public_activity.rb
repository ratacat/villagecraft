module PublicActivity
  module ORM
    module ActiveRecord
      class Activity < ::ActiveRecord::Base
        has_many :notifications
      end
    end
  end
end
