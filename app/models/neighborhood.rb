class Neighborhood < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state_code
      obj.county = geo.sub_state
    end
  end

  def as_geo_json
    @hood = Neighborhood.select('*, ST_AsGeoJSON(geom) as json').where(:id => self.id).first
    @hood.try(:json)
  end

  def as_simplified_geo_json(tolerance = 0.1)
    @hood = Neighborhood.select("*, ST_AsGeoJSON(ST_SimplifyPreserveTopology(geom, #{tolerance})) as json").where(:id => self.id).first
    @hood.try(:json)
  end
  
  def as_gmap_polygons(options={})
    defaults = {
      :color => '0x1450B4',
      :fillcolor => '0x1450B4',
      :tolerance => 0.0005
    }
    options.reverse_merge!(defaults)
    
    json_poly = self.as_simplified_geo_json(options[:tolerance])
    polys = JSON.parse(json_poly)["coordinates"]

    gmap_polys = []
    polys.each do |poly|
      gmap_poly = MapPolygon.new(:color => options[:color], :fillcolor => options[:fillcolor])
      poly.each do |p|
        gmap_poly.points << MapLocation.new(:latitude => p.last, :longitude => p.first)        
      end
      gmap_polys << gmap_poly
    end

    return gmap_polys
  end

  def as_kml
    @hood = Neighborhood.select('*, ST_AsKML(geom) as kml').where(:id => self.id).first
    @hood.try(:kml)
  end
  
  def point_in_hood
    @hood = Neighborhood.select('*, ST_AsText(ST_PointOnSurface(geom)) as pih').where(:id => self.id).first
    @hood.pih.split(/[\(\) ]/)[1,2]
  end
  
  def geom_srid
    @hood = Neighborhood.select('*, ST_SRID(geom) as srid').where(:id => self.id).first
    @hood.try(:srid)
  end
  
  def latitude
    self.point_in_hood.last.to_f
  end

  def longitude
    self.point_in_hood.first.to_f
  end

  def Neighborhood.find_by_lat_lon(lat, lon)
    # FIXME: sanity-check lat, lon
    Neighborhood.where("ST_Within(ST_SetSRID(ST_MakePoint(#{lon},#{lat}), 4326), geom)=true").first
  end
  
  
  
end
