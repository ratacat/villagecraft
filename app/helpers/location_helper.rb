module LocationHelper
  def link_to_google_maps(location, text=nil)
    link_to(text || location.address, "http://maps.google.com/?#{location.address.to_query('q')}")
  end
  
  def map_image(location)
    image_tag "http://maps.google.com/maps/api/staticmap?size=450x300&sensor=false&zoom=16&markers=#{location.latitude}%2C#{location.longitude}", :class => "img-polaroid"
  end
  
  def linked_map_image(location)
    link_to_google_maps(location, map_image(location))
  end
  
  def city_n_state(location)
    "#{location.city}, #{location.state_code}"
  end
  
  def neighborhood_or_city_n_state(location, options={})
    content_tag(:div, :class => 'blocky_spans') do
      content_tag(:span, (location.neighborhood ? location.neighborhood.name : 'somewhere in')) + 
      content_tag(:span, city_n_state(location), :class => 'muted')
    end
  end
  
end
