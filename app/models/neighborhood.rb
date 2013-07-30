class Neighborhood < ActiveRecord::Base

  def Neighborhood.find_by_lat_lon(lat, lon)
    # FIXME: sanity-check lat, lon
    Neighborhood.where("ST_Within(ST_SetSRID(ST_MakePoint(#{lon},#{lat}), 4269), geom)=true").first
  end
  
end
