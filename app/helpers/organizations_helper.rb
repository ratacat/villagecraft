module OrganizationsHelper
  def organization_line_for_event(organization)

    content_tag(:div, class: "row form-group") do
      content_tag(:div, class: "col-xs-10") do
        content_tag(:p, class: "alert alert-info") do
          organization.name
        end+
            hidden_field_tag('event[organization_ids][]', organization.id, id: "event_organization_ids_#{organization.id}")
      end+
          content_tag(:div, class: 'col-xs-2') do
            link_to("#", class: "remove_organization btn btn-danger") do
              content_tag(:i, '', class: "fa fa-times")
            end
          end
    end

  end
end