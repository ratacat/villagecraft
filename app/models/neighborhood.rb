class Neighborhood < ActiveRecord::Base
  attr_accessible :name, :city, :state, :county
  has_many :locations, :conditions => {:deleted_at => nil}
  has_many :venues, :through => :locations
  validates :name, :presence => true, :uniqueness => {:scope => [:city, :state]}
  validates :state, :length => {is: 2}

  after_save :check_whether_any_locations_sans_hood_are_in_the_new_hood
  
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
  
  def Neighborhood.new_from_kml_fn(kml_fn)
    db_config = ActiveRecord::Base.configurations[Rails.env]
    host = db_config["host"]
    db = db_config["database"]
    username = db_config["username"]
    password = db_config["password"]
    ogr2ogr_options = '-append -nlt MULTIPOLYGON -nln neighborhoods -f "PostgreSQL"'
    gdal_data_path = Rails.env.development? ? "/Applications/Postgres.app/Contents/MacOS/share/gdal" : '/usr/local/share/gdal'
    `export GDAL_DATA=#{gdal_data_path}; ogr2ogr #{ogr2ogr_options} PG:"host=#{host} user=#{username} dbname=#{db} password=#{password}" #{kml_fn}`

    Neighborhood.where(:city => nil).each do |hood|
      hood.reverse_geocode
      if hood.save
        Location.where(:state_code => hood.state, :city => hood.city).each do |loc|
          loc.save
        end
      else
        hood.destroy  # destroy the invalid hood
      end
    end
  end

  def Neighborhood.new_from_kml(kml_doc, name=nil)
    # FIXME if name is nil, try to extract from KML doc
    xml_doc  = Nokogiri::XML(kml_doc)
    kml = xml_doc.css("Polygon").first.to_s
    new_id = Neighborhood.connection.insert("INSERT INTO neighborhoods (name, geom) VALUES ('#{name}', ST_Force_2D(ST_Multi(ST_GeomFromKML('#{kml}'))))") 
    if new_id
      hood = Neighborhood.find(new_id)
      hood.reverse_geocode
      hood.destroy unless hood.save
    end
  end
  
  protected
  def check_whether_any_locations_sans_hood_are_in_the_new_hood
    Location.where(:neighborhood_id => nil).readonly(false) do |location|
      location.lookup_and_set_neighborhood
    end    
  end
  
end
