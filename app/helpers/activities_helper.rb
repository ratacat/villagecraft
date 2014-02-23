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
    html = ''.html_safe

    html << '<div class="activity">'.html_safe
    # Somebody...
    unless options[:profile_image_size] === :none
      html << %Q(<div class="pull-left activity_thumb #{options[:profile_image_size]}">).html_safe
      html << user_thumb(activity.owner, :size => options[:profile_image_size], :linked => (not options[:plaintext]), :only_path => options[:only_path])      
      html << '</div>'.html_safe
    end
    html << '<div class="activity_body">'.html_safe
    if options[:plaintext]
      html << content_tag(:strong, contextualized_user_name(activity.owner, :capitalize => true, :viewer => options[:viewer]))
    else
      html << contextualized_user_link(activity.owner, :capitalize => true, :viewer => options[:viewer], :only_path => options[:only_path]).html_safe
    end
    verb_person = (activity.owner === options[:viewer]) ? :second : :third
    html << ' '.html_safe

    # Did something...
    case activity.key
    when 'meeting.time_changed'
      html << 'changed the meeting time'.html_safe
    when 'meeting.venue_changed'
      html << 'changed the meeting venue'.html_safe
    when 'event.create'
      html << 'created the event'.html_safe
    when 'event.interested'
      html << "#{:be.verb.conjugate :person => verb_person} interested in attending".html_safe
    when 'event.attend'
      html << "#{:plan.verb.conjugate :person => verb_person} to attend".html_safe
    when 'event.cancel_attend'
      html << "no longer #{:plan.verb.conjugate :person => verb_person} to attend".html_safe
    when 'event.host_cancels_attend'
      html << "are no longer signed up to attend".html_safe
    when 'event.sms'
      html << "sent a message to the attendees of".html_safe
    when 'event.email'
      html << "emailed ".html_safe
      message = Message.find_by_uuid(activity.parameters[:uuid])
      if message.blank?
        html << 'a message that is no-longer available'.html_safe
      else
        html << link_to('a message', message)        
      end
      html << " to the attendees of".html_safe
    else
      if /(.*)\.(create|update|destroy)/.match(activity.key)
        html << "#{($2).verb.conjugate :person => verb_person, :tense => :past, :aspect => :perfective}"
        html << " the #{$1}" if activity.trackable
      else
        html << 'did something to'.html_safe
      end
    end
    html << ' '.html_safe

    # To something...
    if options[:show_trackable]
      trackable = activity.trackable
      case activity.key
      when 'meeting.time_changed', 'meeting.venue_changed'
        html << 'of '.html_safe
      else
        ''
      end
      if options[:plaintext]
        html << content_tag(:strong, trackable.title)
      else
        if trackable.blank?
          html  << "a #{activity.trackable_type.downcase} that no longer exists"
        else
          html << link_to(trackable.title, polymorphic_url(trackable, :only_path => options[:only_path]))
        end
      end
    end
    html << ' '.html_safe
    
    # Extra info about what happened (e.g. time or venue changed to what?)...
    case activity.key
    when 'event.host_cancels_attend'
      html << "(the host has cancelled your attendance)".html_safe
    when 'meeting.time_changed'
      html << "to #{activity.parameters[:new_time]}"
    when 'meeting.venue_changed'
      venue = Venue.find_by_id(activity.parameters[:new_venue_id])
      html << "to ".html_safe
      html << inline_venue(venue, :linked => (not options[:plaintext]), :only_path => options[:only_path])
    end
    
    # Muted line below main activity line
    html << '<div class="muted">'.html_safe
    # At a certain time...
    if options[:show_ago]
      html << time_ago(activity.created_at)
    end
    
    # Extra html if there is any (e.g. "5 similar activities hidden")
    if options[:extra_html]
      html << " &#xb7; ".html_safe
      html << options[:extra_html]
    end
    html << '</div>'.html_safe   # close <div class="muted">
    
    # Activity body (image thumbnail, new venue, new time, SMS message, etc.)
    case activity.key
    when 'event.sms'
      html << ': "'.html_safe if options[:plaintext]
      html << content_tag(:blockquote, activity.parameters[:message], :class => "fancy indent-#{options[:profile_image_size]}")
      html << '"'.html_safe if options[:plaintext]
    end
    
    html << '</div>'.html_safe   # close <div class="activity_body">
    html << '</div>'.html_safe   # close <div class="activity">
    html
  end
end
