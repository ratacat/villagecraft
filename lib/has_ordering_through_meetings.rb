module ActiveRecord
  module Has
    module OrderingThroughMeetings
      extend ActiveSupport::Concern
            
      module ClassMethods
        def ordered_by_first_meeting_start_time
          joins(:first_meeting).order(%Q(#{Meeting.quoted_table_column(:start_time)}))
        end

        def ordered_by_earliest_meeting_start_time
          joins(:meetings)
          .select(%Q(#{self.quoted_table_name}.*, min(#{Meeting.quoted_table_column(:start_time)}) as earliest_start_time))
          .group(self.quoted_table_column(:id))
          .order(:earliest_start_time)
        end
        
        def ordered_by_latest_meeting_end_time
          joins(:meetings)
          .select(%Q(#{self.quoted_table_name}.*, max(#{Meeting.quoted_table_column(:end_time)}) as latest_end_time))
          .group(self.quoted_table_column(:id))
          .order(:latest_end_time)
          .reverse_order
        end

        def with_meeting_starting_before(t)
          joins(:meetings).where(%Q(#{Meeting.quoted_table_column(:start_time)} < ?), t)
        end
        
        def with_meeting_starting_after(t)
          joins(:meetings).where(%Q(#{Meeting.quoted_table_column(:start_time)} > ?), t)
        end

        def where_first_meeting_starting_before(t)
          joins(:first_meeting).where(%Q(#{Meeting.quoted_table_column(:start_time)} < ?), t)
        end
        
        def where_first_meeting_starting_after(t)
          joins(:first_meeting).where(%Q(#{Meeting.quoted_table_column(:start_time)} > ?), t)
        end

        def where_first_meeting_ending_before(t)
          joins(:first_meeting).where(%Q(#{Meeting.quoted_table_column(:end_time)} < ?), t)
        end
        
        def where_first_meeting_ending_after(t)
          joins(:first_meeting).where(%Q(#{Meeting.quoted_table_column(:end_time)} > ?), t)
        end
        
        def where_first_meeting_starts_in_future
          where_first_meeting_starting_after(Time.now).ordered_by_first_meeting_start_time
        end

        def where_first_meeting_ends_in_future
          where_first_meeting_ending_after(Time.now).ordered_by_first_meeting_start_time
        end
        
        def where_first_meeting_starts_in_past
          where_first_meeting_starting_before(Time.now).ordered_by_first_meeting_start_time.reverse_order
        end
      end
    end
  end
end

# include the extension 
# ActiveRecord::Base.send(:include, ActiveRecord::Has::OrderingThroughMeetings)
