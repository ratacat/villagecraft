class Neighborhood < ActiveRecord::Base

  def as_geo_json
    @hood = Neighborhood.select('*, ST_AsGeoJSON(geom) as json').where(:id => self.id).first
    @hood.try(:json)
  end

  def as_kml
    @hood = Neighborhood.select('*, ST_AsKML(geom) as kml').where(:id => self.id).first
    @hood.try(:kml)
  end

  def Neighborhood.find_by_lat_lon(lat, lon)
    # FIXME: sanity-check lat, lon
    Neighborhood.where("ST_Within(ST_SetSRID(ST_MakePoint(#{lon},#{lat}), 4269), geom)=true").first
  end
  
end
