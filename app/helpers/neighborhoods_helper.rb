module NeighborhoodsHelper
  def static_gmap_url(neighborhood)
    map = GoogleStaticMap.new(:width => 470, :height => 310)
    neighborhood.as_gmap_polygons.each do |poly|
      map.paths << poly
    end
    map.url
  end
end
