module MeetingsHelper
  def meeting_time(meeting, options = {})
    defaults = {
      :short_date => false,
      :show_livestamp => false,
      :no_tz => false,
      :tag => :span
    }
    options.reverse_merge!(defaults)
    options[:date_format] = options[:short_date] ? "%A %b" : "%A %B"

    html = content_tag(options[:tag], meeting.localized_start_time.strftime(options[:date_format] + " #{meeting.start_time.day.ordinalize}"))
    html += content_tag(options[:tag], "#{l meeting.localized_start_time, format: :short_time} - #{l meeting.localized_end_time, format: :short_time}")

    if options[:show_livestamp]
      html += content_tag(options[:tag], '', :class => 'muted', :'data-livestamp' => meeting.start_time)
    end
    unless options[:no_tz]
      content_tag(options[:tag], friendly_time_zone_name(meeting.time_zone), :class => 'time_zone')
    end
    html.html_safe
  end
  
end
