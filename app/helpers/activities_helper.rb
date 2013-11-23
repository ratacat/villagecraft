module ActivitiesHelper
  def render_activity(activity, options)
    defaults = {
      :profile_image_size => :thumb, 
      :show_trackable => false,
      :plaintext => false,
      :only_path => false,
      :show_ago => true
    }
    options.reverse_merge!(defaults)
    options[:viewer] ||= current_user
    html = []

    html << '<div class="activity">'
    # Somebody...
    unless options[:profile_image_size] === :none
      html << %Q(<div class="pull-left activity_thumb #{options[:profile_image_size]}">)
      html << user_thumb(activity.owner, :size => options[:profile_image_size], :linked => (not options[:plaintext]), :only_path => options[:only_path])      
      html << '</div>'
    end
    html << '<div class="activity_body">'
    if options[:plaintext]
      html << content_tag(:strong, contextualized_user_name(activity.owner, :capitalize => true, :viewer => options[:viewer]))
    else
      html << contextualized_user_link(activity.owner, :capitalize => true, :viewer => options[:viewer], :only_path => options[:only_path])
    end
    verb_person = (activity.owner === options[:viewer]) ? :second : :third

    # Did something...
    case activity.key
    when 'meeting.time_changed'
      html << 'changed the meeting time'
    when 'meeting.venue_changed'
      html << 'changed the meeting venue'
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

    # To something...
    if options[:show_trackable]
      trackable = activity.trackable
      case activity.key
      when 'meeting.time_changed', 'meeting.venue_changed'
        html << 'of'
      else
        ''
      end
      if options[:plaintext]
        html << content_tag(:strong, trackable.title)
      else
        if trackable.blank?
          html  << "trackable nil for activity: #{activity.id}"
        else
          html << link_to(trackable.title, polymorphic_url(trackable, :only_path => options[:only_path]))
        end
      end
    end
    
    # Extra info about what happened (e.g. time or venue changed to what?)...
    case activity.key
    when 'event.host_cancels_attend'
      html << "(the host has cancelled your attendance)"
    when 'meeting.time_changed'
      html << "to #{activity.parameters[:new_time]}"
    when 'meeting.venue_changed'
      venue = Venue.find_by_id(activity.parameters[:new_venue_id])
      html << "to "
      html << inline_venue(venue, :linked => (not options[:plaintext]), :only_path => options[:only_path])
    else
      ''
    end
    
    # At a certain time...
    if options[:show_ago]
      html << content_tag(:div, time_ago(activity.created_at))      
    end
    html << '</div>'   # close <div class="activity_body">
    html << '</div>'   # close <div class="activity">
    html.join(' ').html_safe
    

  end
end
