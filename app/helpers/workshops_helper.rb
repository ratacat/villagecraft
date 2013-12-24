module WorkshopsHelper
  def annotated_workshop_title(workshop, options={})
    html = workshop.title
    if workshop.external?
      html += " " + content_tag(:i, '', :class => 'icon-external-link')      
    end
    html.html_safe
  end
end
