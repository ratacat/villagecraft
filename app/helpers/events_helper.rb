module EventsHelper
  def event_price(event, options={})
    defaults = {
      :show_materials_fee => false
    }
    options.reverse_merge!(defaults)
    
    if event.price.blank?
      'Free!'
    else
      html = number_to_currency(event.price)
      html += ' materials fee' if options[:show_materials_fee]
      html
    end
  end
  alias :rerun_price :event_price
  
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

end
