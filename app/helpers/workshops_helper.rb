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
  
  def external_domain(workshop)
    content_tag(:span, " (#{domain_suffix(workshop.external_url)})", :class => 'external_domain').html_safe
  end
  
  def seod_title(workshop)
    limit = 65
    next_rerun = workshop.ongoing_or_next_rerun
    location = next_rerun.try(:location) || workshop.venue.try(:location)
    location_part = city_n_state(location)
    title_part = workshop.title.truncate(limit - " in ".size - location_part.size)
    "#{title_part} in #{location_part}"
  end
  
end
