module MeetingsHelper
  def meeting_time(meeting, options = {})
    defaults = {
      :short_date => false,
      :show_livestamp => false,
      :no_tz => false,
      :wrapper_tag => nil,
      :wrapper_options => {}
    }
    options.reverse_merge!(defaults)
    options[:date_format] = options[:short_date] ? "%A %b" : "%A %B"

    html = []
    html << content_tag(:span, meeting.localized_start_time.strftime(options[:date_format] + " #{meeting.start_time.day.ordinalize}"), :class => 'date')
    html << content_tag(:span, "#{l meeting.localized_start_time, format: :short_time} - #{l meeting.localized_end_time, format: :short_time}", 
                        :'data-start_time_date' => l(meeting.localized_start_time, format: :date_picker_date_format).strip,
                        :'data-start_time_time' => l(meeting.localized_start_time, format: :time_picker_time_format).strip,
                        :'data-end_time_date' => l(meeting.localized_end_time, format: :date_picker_date_format).strip,
                        :'data-end_time_time' => l(meeting.localized_end_time, format: :time_picker_time_format).strip,
                        :'data-uuid' => meeting.uuid,
                        :class => 'time_range')
    if options[:show_livestamp]
      html << content_tag(:span, '', :class => 'muted', :'data-livestamp' => meeting.start_time)
    end
    unless options[:no_tz]
      html << content_tag(:span, friendly_time_zone_name(meeting.time_zone), :class => 'time_zone')
    end
    if options[:wrapper_tag]
      html.map! {|e| content_tag(options[:wrapper_tag], e, options[:wrapper_options]) }
    end
    html.join('').html_safe
  end
  
end
