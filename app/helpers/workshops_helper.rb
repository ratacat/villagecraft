module WorkshopsHelper
  def annotated_workshop_title(workshop, options={})
    defaults = {
      :linked_to => nil
    }
    options.reverse_merge!(defaults)
    options[:linked_to] = workshop_path(workshop) if options[:linked_to] === true
    
    html = workshop.title
    html = link_to(html, options[:linked_to], :title => "#{'external workshop' if workshop.external?}") if options[:linked_to]
    
    if workshop.external? and not workshop.external_url.blank?
      html += content_tag(:span, " (#{domain_suffix(workshop.external_url)})", :class => 'domain_annotation')
    end
    html.html_safe
  end
end
