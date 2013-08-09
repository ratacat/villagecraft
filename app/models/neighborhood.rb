class Neighborhood < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state_code
    end
  end

  def as_geo_json
    @hood = Neighborhood.select('*, ST_AsGeoJSON(geom) as json').where(:id => self.id).first
    @hood.try(:json)
  end

  def as_kml
    @hood = Neighborhood.select('*, ST_AsKML(geom) as kml').where(:id => self.id).first
    @hood.try(:kml)
  end
  
  def point_in_hood
    @hood = Neighborhood.select('*, ST_AsText(ST_PointOnSurface(geom)) as pih').where(:id => self.id).first
    @hood.pih.split(/[\(\) ]/)[1,2]
  end
  
  def latitude
    self.point_in_hood.last.to_f
  end

  def longitude
    self.point_in_hood.first.to_f
  end

  def Neighborhood.find_by_lat_lon(lat, lon)
    # FIXME: sanity-check lat, lon
    Neighborhood.where("ST_Within(ST_SetSRID(ST_MakePoint(#{lon},#{lat}), 4269), geom)=true").first
  end
  
  
  
end
