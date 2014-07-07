module EventsHelper
  def event_price(event, options={})
    defaults = {
        :show_materials_fee => false,
        :free_msg => 'Free'
    }
    options.reverse_merge!(defaults)

    if event.price.blank? or event.price === 0
      options[:free_msg]
    else
      html = number_to_currency(event.price, :precision => 0)
      html += ' materials fee' if options[:show_materials_fee]
      html
    end
  end
  alias :rerun_price :event_price

  def sign_up_link(event, options = {})
    defaults = {
        :show_check => false,
        :cta => 'Sign up',
        :buttonize => false,
        :block_buttonize => false,
        :path => nil,
        :remote => false
    }
    options.reverse_merge!(defaults)
  
    if options[:buttonize] or options[:block_buttonize]
      classes = %w(btn btn-success attend_event)
    else
      classes = %w(attend_event)
    end
    classes << 'btn-block' if options[:block_buttonize]
    
    if user_signed_in?
      link_to_options = {class: classes.join(' '), method: :post, remote: options[:remote], data: {type: options[:remote] ? :json : :html}}
    else
      link_to_options = {class: classes.join(' '), 
                         data: {:auto_attend_event => event.uuid, :auto_attend_event_title => event.title, :toggle_modal_registration => true} }
    end
  
    link_to (options[:path] || attend_path(event)), link_to_options do
      (options[:show_check] ? content_tag(:i, '', :class => "glyphicon glyphicon-ok") : '') + options[:cta]
    end
  end

  def event_price_css_able?(event)
    # under 20; 25-50 and a multple of 5
    p = event.price
    p.blank? or (p < 20) or (p <= 50 and p%5 ===0)
  end

  def event_price_css(event, options={})
    defaults = {
        :show_materials_fee => false
    }
    options.reverse_merge!(defaults)

    if event.price.blank? or event.price === 0
      content_tag(:span,'', :class => "bio free_1")
    else
      html = content_tag(:span,'',:class => "bio nr_dolar")+
          content_tag(:span,'',:class => "bio nr_#{event.price.to_i}")
      html += content_tag(:span,' materials fee') if options[:show_materials_fee]
      html
    end
  end
  alias :rerun_price_css :event_price_css

  def annotated_event_title(event, options={})
    html = ''.html_safe
    html << event.title
    if event.external?
      html << " ".html_safe
      html << content_tag(:i, '', :class => 'icon-external-link').html_safe
    end
    html
  end

  def blur_event_location?(event)
    not (user_signed_in? and (current_user === event.host or current_user.attending_event?(event)))
  end

  def attends_status(event, options={})
    defaults = {
        :show_interest => false
    }
    options.reverse_merge!(defaults)

    attends = event.attendances.count
#    attends = event.attendances.with_state(:attending).count
#    applied = event.attendances.with_state(:interested).count

    html = "#{pluralize(attends, 'attendee')}"
    if options[:show_interest]
      html += " (#{applied} interested)" if applied > 0
    end
    html
  end

  def event_size(event)
    "#{event.min_attendees}-#{event.max_attendees} attendees"
  end

  def slots_status(event)
    attends = event.attendances.count
#    attends = event.attendances.with_state(:attending).count
    min = event.min_attendees
    max = event.max_attendees

    if attends < min
      "need #{min - attends} more"
    else
      "#{(attends < max) ? pluralize(max - attends, 'slot') : 'no slots'} left"
    end
  end

  def event_date(event, options = {})
    defaults = {
        :short_date => false
    }
    options.reverse_merge!(defaults)
    options[:date_format] ||= (options[:short_date] ? "%A %b" : "%A %B")
    day = event.localized_start_time.day
    event.localized_start_time.strftime(options[:date_format] + " #{(options[:short_date] ? day : day.ordinalize)}")
  end

  def event_time_interval(event)
    if event.end_time.present? and event.start_time.present?
      if event.end_time - event.start_time >= 2.days
        time_interval = "#{I18n.l event.localized_start_time, format: :short_time} (ending #{distance_of_time_in_words(event.start_time, event.end_time)} later)"
      else
        time_interval = "#{I18n.l event.localized_start_time, format: :short_time} - #{I18n.l event.localized_end_time, format: :short_time}"
        time_interval += " (+ #{distance_of_time_in_words(event.start_time, event.end_time)})" if event.end_time - event.start_time >= 1.day
      end
      time_interval
    end
  end

  def event_time(event, options = {})
    defaults = {
        :short_date => false,
        :show_date => true,
        :show_end_time => true,
        :show_livestamp => false,
        :no_tz => false,
        :wrapper_tag => nil,
        :spacer => nil,
        :plaintext => false,
        :wrapper_options => {}
    }
    options.reverse_merge!(defaults)
    html = []
    if options[:show_date]
      options[:date_format] = options[:date_format] || (options[:short_date] ? "%A %b" : "%A %B")
      html << content_tag(:span, event_date(event, options), :class => 'date')
      html << options[:spacer] if options[:spacer]
    end
    if options[:show_end_time]
      html << content_tag(:span, event_time_interval(event),
                          :'data-start_time_date' => l(event.localized_start_time, format: :date_picker_date_format).strip,
                          :'data-start_time_time' => l(event.localized_start_time, format: :time_picker_time_format).strip,
                          :'data-end_time_date' => l(event.localized_end_time, format: :date_picker_date_format).strip,
                          :'data-end_time_time' => l(event.localized_end_time, format: :time_picker_time_format).strip,
                          :'data-uuid' => event.uuid,
                          :class => 'time_range')
    else
      html << content_tag(:span, I18n.l(event.localized_start_time, format: :short_time))
    end
    if options[:show_livestamp]
      html << options[:spacer] if options[:spacer]
      html << content_tag(:span, '', :class => 'text-muted', :'data-livestamp' => event.start_time)
    end
    unless options[:no_tz]
      html << options[:spacer] if options[:spacer]
      html << content_tag(:span, friendly_time_zone_name(event.time_zone), :class => 'time_zone')
    end
    if options[:wrapper_tag]
      html.map! {|e| content_tag(options[:wrapper_tag], e, options[:wrapper_options]) }
    end
    html = html.join('').html_safe
    if options[:plaintext]
      html = strip_tags(html)
    end
    return html
  end

end
