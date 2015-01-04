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
  
  def event_locked_title(event)
    %Q(Event locked because #{pluralize(event.attendances.count, "attendee")} signed up)
  end
  
  def event_unlock_confirmation(event)
    %Q(This event is locked because #{pluralize(event.attendances.count, "person")} signed up. You may unlock it to make changes, but tread carefully! Anyone signed up will be notified of each change you make.)
  end

  def event_unlocked_warning(event)
    %Q(Tread carefully! #{pluralize(event.attendances.count, "attendee")} signed up who will be notified of any changes you make)
  end

end
