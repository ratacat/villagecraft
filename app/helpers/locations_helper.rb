module LocationsHelper
  def link_to_google_maps(location, text=nil)
    link_to(text || location.address, "http://maps.google.com/?#{location.address.to_query('q')}")
  end
  
  def map_image(location)
    image_tag "http://maps.google.com/maps/api/staticmap?size=450x300&sensor=false&zoom=16&markers=#{location.latitude}%2C#{location.longitude}", :class => "img-polaroid"
  end
  
  def linked_map_image(location)
    link_to_google_maps(location, map_image(location))
  end
  
  def city_n_state(location, options={})
    defaults = {
      :show_state => true
    }
    options.reverse_merge!(defaults)
    
    html = location.city.titlecase
    html << ", #{location.state_code.upcase}" if options[:show_state]
    html
  end
  
  def popover_neighborhood_map(location)
    if location.neighborhood
      %Q(<img src="#{static_gmap_url(location.neighborhood)}"/>)
    else
      render(:partial => 'locations/embedded_gmap', :locals => {:q => city_n_state(location)})
    end
  end
  
  def hood_name_in_city(location, options={})
    defaults = {
      :show_in => false,
      :show_state => true
    }
    options.reverse_merge!(defaults)
    
    content_tag(:span, (location.neighborhood ? location.neighborhood.name + "#{' in ' if options[:show_in]}" : 'Somewhere in ')) + 
    content_tag(:span, city_n_state(location, show_state: options[:show_state]), :class => 'text-muted')
  end
  
  def address(location, options={})
    defaults = {
      :show_popover_map => false,
      :wrapper_tag => :div,
      :address => nil,
      :show_street => true,
      :show_hood => true,
      :show_city => true,
      :show_state => true
    }
    options.reverse_merge!(defaults)

    content_tag(options[:wrapper_tag], :class => "blocky_spns#{ ' popover_map' if options[:show_popover_map]}", 
                      :'data-content' => popover_neighborhood_map(location), 
                      :'data-title' => hood_name_in_city(location, :show_in => true).gsub('"', "'")) do
      if options[:address]
        options[:address]
      else
        html = ''.html_safe
        html << content_tag(:span, location.street) if options[:show_street]
        if options[:show_hood]
          html << hood_name_in_city(location, show_state: options[:show_state])
        else
          html << content_tag(:span, city_n_state(location, show_state: options[:show_state])) if options[:show_city_n_state]
        end
        html
      end
    end    
  end
  
  def neighborhood_or_city_n_state(location, options={})
    defaults = {
      :show_popover_map => false,
      :wrapper_tag => :div
    }
    options.reverse_merge!(defaults)
    
    content_tag(options[:wrapper_tag], :class => "blocky_spns#{ ' popover_map' if options[:show_popover_map]}", 
                      :'data-content' => popover_neighborhood_map(location), 
                      :'data-title' => hood_name_in_city(location, :show_in => true).gsub('"', "'")) do
      hood_name_in_city(location)
    end
  end
  
  def distance(d)
    units = current_user.try(:preferred_distance_units) || 'mi'
    m_to_units_multiplier = {:mi => 0.000621371, :km => 0.001}
    "#{number_with_precision((d.to_f * m_to_units_multiplier[units.to_sym]), precision: 1)}#{units}"
  end
  
end
