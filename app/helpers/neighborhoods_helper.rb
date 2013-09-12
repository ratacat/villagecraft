module NeighborhoodsHelper
  def static_gmap_url(neighborhood)
    map = GoogleStaticMap.new(:width => 470, :height => 310)
    neighborhood.as_gmap_polygons.each do |poly|
      map.paths << poly
    end
    begin
      map.url
    rescue Exception => e
      # Sometimes we get the exception: "Need more than one point for the path"
      # FIXME return some sort of fail URL
    end
  end
end
