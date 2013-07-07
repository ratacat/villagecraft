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
  
end
