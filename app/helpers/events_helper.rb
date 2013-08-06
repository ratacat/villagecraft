module EventsHelper
  def event_price(event)
    if event.price.blank?
      'Free!'
    else
      number_to_currency(event.price)      
    end
  end
  
  def blur_event_location?(event)
    not (user_signed_in? and (current_user === event.host or current_user.attending_event?(event)))
  end
  
  def event_action(activity, options={})
    defaults = {:profile_image_size => :thumb}
    options.reverse_merge!(defaults)
    event = activity.trackable
    html = []
    html << linked_user_thumb(activity.owner, :size => options[:profile_image_size])
    html << '<div class="caption">'
    html << contextualized_user_link(activity.owner, :capitalize => true)
    case activity.key
    when 'event.time_changed'
      html << 'changed the time'
    when 'event.venue_changed'
      html << 'changed the venue'
    when 'event.create'
      html << 'created the event'
    when 'event.attend'
      html << "#{conjugate('plan', :second_person => activity.owner === current_user)} to attend"
    when 'event.cancel_attend'
      html << "no longer #{conjugate('plan', :second_person => activity.owner === current_user)} to attend"
    else
      ''
    end
    if options[:link_to_event]
      case activity.key
      when 'event.time_changed', 'event.venue_changed'
        html << 'of'
      else
        ''
      end
      html << link_to(event.title, event)
    end
    case activity.key
    when 'event.time_changed'
      html << "to #{activity.parameters[:new_time]}"
    when 'event.venue_changed'
      html << "to #{link_to(event.venue.name, event.venue)}"
    else
      ''
    end
    html << content_tag(:div, time_ago(activity.created_at))
    html << '</div>'
    html.join(' ').html_safe
  end
end
