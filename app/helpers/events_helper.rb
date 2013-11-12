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
  
  def blur_event_location?(event)
    not (user_signed_in? and (current_user === event.host or current_user.attending_event?(event)))
  end
  
  def attends_status(event, options={})
    defaults = {
      :show_interest => false
    }
    options.reverse_merge!(defaults)
    
    attends = event.attendances.with_state(:attending).count
    applied = event.attendances.with_state(:interested).count

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
    attends = event.attendances.with_state(:attending).count
    min = event.min_attendees
    max = event.max_attendees

    if attends < min
      "need #{min - attends} more"
    else
      "#{(attends < max) ? pluralize(max - attends, 'slot') : 'no slots'} left"
    end
  end
  
  def event_action(activity, options={})
    defaults = {
      :profile_image_size => :thumb, 
      :show_trackable => false,
      :plaintext => false,
      :only_path => false,
      :show_ago => true
    }
    options.reverse_merge!(defaults)
    options[:viewer] ||= current_user
    event = activity.trackable
    html = []
    unless options[:profile_image_size] === :none
      html << user_thumb(activity.owner, :size => options[:profile_image_size], :linked => (not options[:plaintext]), :only_path => options[:only_path])      
    end
    html << '<div class="caption">'
    if options[:plaintext]
      html << content_tag(:strong, contextualized_user_name(activity.owner, :capitalize => true, :viewer => options[:viewer]))
    else
      html << contextualized_user_link(activity.owner, :capitalize => true, :viewer => options[:viewer], :only_path => options[:only_path])
    end
    verb_person = (activity.owner === options[:viewer]) ? :second : :third
    case activity.key
    when 'event.time_changed'
      html << 'changed the time'
    when 'event.venue_changed'
      html << 'changed the venue'
    when 'event.create'
      html << 'created the event'
    when 'event.interested'
      html << "#{:be.verb.conjugate :person => verb_person} interested in attending"
    when 'event.attend'
      html << "#{:plan.verb.conjugate :person => verb_person} to attend"
    when 'event.cancel_attend'
      html << "no longer #{:plan.verb.conjugate :person => verb_person} to attend"
    when 'event.host_cancels_attend'
      html << "are no longer signed up to attend"
    else
      ''
    end
    if options[:show_trackable]
      case activity.key
      when 'event.time_changed', 'event.venue_changed'
        html << 'of'
      else
        ''
      end
      if options[:plaintext]
        html << content_tag(:strong, event.title)
      else
        html << link_to(event.title, root_url(:only_path => options[:only_path], :anchor => event.to_param))
      end
    end
    case activity.key
    when 'event.host_cancels_attend'
      html << "(the host has cancelled your attendance)"
    when 'event.time_changed'
      html << "to #{activity.parameters[:new_time]}"
    when 'event.venue_changed'
      venue = Venue.find_by_id(activity.parameters[:new_venue_id])
      html << "to "
      if venue.blank?
        html << 'TBD'
      else
        if options[:plaintext]
          html << content_tag(:strong, venue.name)
        else
          html << link_to(venue.name, venue_url(venue, :only_path => options[:only_path]))
        end
      end
    else
      ''
    end
    if options[:show_ago]
      html << content_tag(:div, time_ago(activity.created_at))      
    end
    html << '</div>'
    html.join(' ').html_safe
  end
end
