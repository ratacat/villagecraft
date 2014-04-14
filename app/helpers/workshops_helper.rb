module WorkshopsHelper
  def annotated_workshop_title(workshop, options={})
    defaults = {
      :linked_to => nil
    }
    options.reverse_merge!(defaults)
    options[:linked_to] = workshop_path(workshop) if options[:linked_to] === true
    
    html = ''.html_safe

    if options[:linked_to]
      html << link_to(workshop.title, options[:linked_to], :title => "#{'external workshop' if workshop.external?}")
    else
      html << workshop.title
    end
  
    if workshop.external? and not workshop.external_url.blank?
      html << external_domain(workshop)
    end
    html
  end
  alias :workshop_title :annotated_workshop_title
  
  def external_domain(workshop)
    content_tag(:span, domain_suffix(workshop.external_url), :class => 'external_domain').html_safe
  end
  
  def seod_title(workshop)
    limit = 65
    next_rerun = workshop.ongoing_or_next_rerun
    if location = next_rerun.try(:location) || workshop.venue.try(:location)
      location_part = city_n_state(location)
      title_part = workshop.title.truncate(limit - " in ".size - location_part.size)
      "#{title_part} in #{location_part}"
    else
      workshop.title.truncate(limit)
    end
  end
  
  def workshop_og_meta_tags(workshop)
    tags ={
      title: workshop.title,
      site_name: 'Villagecraft',
      url: workshop_path(only_path: false),
      description: @workshop.meta_description(3),
      image: @workshop.img_src(:original)
    }
    html = ''.html_safe
    tags.each do |key, value|
      html << "\n".html_safe
      html << tag(:meta, property: "og:#{key}", content: value)
    end
    html
  end
  
  def share_by_email(workshop, options={})
    defaults = {
      :signed_up => false,
      :class => ''
    }
    options.reverse_merge!(defaults)
    
    next_rerun = workshop.ongoing_or_next_rerun
    next_meeting = next_rerun.try(:first_meeting)
    meeting_time_text = meeting_time(next_meeting, :plaintext => true, :short_date => true, :no_tz => true, :show_end_time => false) if next_meeting
    
    if current_user.try(:attending_workshop?, workshop) or options[:signed_up]
      subject = %Q(Join me at "#{workshop.title}")
      subject << %Q( (#{meeting_time_text})) if next_meeting # FIXME eventually, user may be signed up for a future one that's not the next one
      body = %Q(I'll be attending this Villagecraft workshop:\n\n#{workshop.title}\n#{workshop_path(workshop, only_path: false)})
      body << %Q(\n#{meeting_time_text}) if next_meeting
      body << %Q(\n\nI hope you can join me!)
    elsif current_user.try(:attended_workshop?, workshop)
      subject = %Q(#{workshop.title})
      subject << %Q( (#{meeting_time_text})) if next_meeting
      body = %Q(I attended the Villagecraft workshop:\n\n#{workshop.title}\n#{workshop_path(workshop, only_path: false)})
      body << %Q(\n\nIt's happening again #{meeting_time_text}.  ) if next_meeting
      body << %Q(Check it out!)
    else
      subject = %Q(#{workshop.title})
      subject << %Q( (#{meeting_time_text})) if next_meeting
      body = %Q(Check out this Villagecraft workshop:\n\n#{workshop.title})
      body << %Q(\n#{workshop_path(workshop, only_path: false)})
      body << %Q(\n#{meeting_time_text}) if next_meeting
    end
    body << %Q(\n\n--#{current_user.name}) if user_signed_in?
    mail_to nil, ' Share by email', subject: subject, body: body, class: "fa fa-envelope-o btn btn-default btn-xs #{options[:class]}", target: '_blank'
  end
  
end
