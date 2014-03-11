module ActiveSupport
  class TimeWithZone
    def previous_oclock(n)
      if self.hour >= n  # same day
        Time.zone.local(self.year, self.month, self.day, n)
      else # previous day
        Time.zone.local(self.year, self.month, self.day, n) - 1.day
      end
    end
    
    def respect_blackout(options = {})
      defaults = {
        :blackout_start => 21,
        :blackout_end => 9,
        :snap_to => nil
      }
      options.reverse_merge!(defaults)
      
      if (self.hour >= options[:blackout_start]) or (self.hour < options[:blackout_end])
        options[:snap_to]
      else
        self
      end
    end
  end
end
