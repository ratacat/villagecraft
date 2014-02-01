module MeetingsHelper
  def meeting_date(meeting, options = {}) 
    defaults = {
      :short_date => false
    }
    options.reverse_merge!(defaults)
    options[:date_format] = options[:short_date] ? "%A %b" : "%A %B"
    meeting.localized_start_time.strftime(options[:date_format] + " #{meeting.localized_start_time.day.ordinalize}")
  end
  
  def meeting_time_interval(meeting)
    if meeting.end_time - meeting.start_time >= 2.days
      time_interval = "#{I18n.l meeting.localized_start_time, format: :short_time} (ending #{distance_of_time_in_words(meeting.start_time, meeting.end_time)} later)"
    else
      time_interval = "#{I18n.l meeting.localized_start_time, format: :short_time} - #{I18n.l meeting.localized_end_time, format: :short_time}"
      time_interval += " (+#{distance_of_time_in_words(meeting.start_time, meeting.end_time)})" if meeting.end_time - meeting.start_time >= 1.day
    end
    time_interval
  end
  
  def plaintext_meeting_time(meeting)
    "#{meeting_date(meeting)} #{meeting_time_interval(meeting)}"
  end
  
  def meeting_time(meeting, options = {})
    defaults = {
      :short_date => false,
      :show_date => true,
      :show_end_time => true,
      :show_livestamp => false,
      :no_tz => false,
      :wrapper_tag => nil,
      :spacer => nil,
      :wrapper_options => {}
    }
    options.reverse_merge!(defaults)
    html = []
    if options[:show_date]
      options[:date_format] = options[:date_format] || (options[:short_date] ? "%A %b" : "%A %B")
      html << content_tag(:span, meeting_date(meeting, :short_date => options[:date_format]), :class => 'date')      
      html << options[:spacer] if options[:spacer]
    end
    if options[:show_end_time]
      html << content_tag(:span, meeting_time_interval(meeting), 
                          :'data-start_time_date' => l(meeting.localized_start_time, format: :date_picker_date_format).strip,
                          :'data-start_time_time' => l(meeting.localized_start_time, format: :time_picker_time_format).strip,
                          :'data-end_time_date' => l(meeting.localized_end_time, format: :date_picker_date_format).strip,
                          :'data-end_time_time' => l(meeting.localized_end_time, format: :time_picker_time_format).strip,
                          :'data-uuid' => meeting.uuid,
                          :class => 'time_range')
    else
      html << I18n.l(meeting.localized_start_time, format: :short_time)
    end
    if options[:show_livestamp]
      html << options[:spacer] if options[:spacer]
      html << content_tag(:span, '', :class => 'muted', :'data-livestamp' => meeting.start_time)
    end
    unless options[:no_tz]
      html << options[:spacer] if options[:spacer]
      html << content_tag(:span, friendly_time_zone_name(meeting.time_zone), :class => 'time_zone')
    end
    if options[:wrapper_tag]
      html.map! {|e| content_tag(options[:wrapper_tag], e, options[:wrapper_options]) }
    end
    html.join('').html_safe
  end
  
end
