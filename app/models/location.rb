class Location < ActiveRecord::Base
  attr_accessible :name, :city, :state_code, :street, :address
  has_many :venues, :conditions => {:deleted_at => nil}
  belongs_to :neighborhood
  acts_as_paranoid

  geocoded_by :address_or_sythesized_address do |obj, results|
    if geo = results.first
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      
      obj.address ||= geo.formatted_address
      
      obj.street ||= geo.street_address
      obj.city ||= geo.city
      obj.state ||= geo.state
      obj.state_code ||= geo.state_code
      obj.zip ||= geo.postal_code
      obj.country ||= geo.country_code
      [obj.latitude, obj.longitude]
    end
  end
  
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.street = geo.street_address  # when given city+state, this is set to some random address at the centroid
      obj.city = geo.city
      obj.state = geo.state
      obj.state_code = geo.state_code
      obj.zip = geo.postal_code
      obj.country = geo.country_code
    end
  end
  before_validation :geocode
  
  # users who have appeared in this location
  has_many :sightings
  has_many :users, :through => :sightings
  
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  
  after_validation :lookup_time_zone, :lookup_neighborhood
  after_save :update_point_from_lon_lat

  def md5hash
    Digest::MD5.hexdigest("#{self.city}#{self.zip}#{self.address}#{self.latitude}#{self.longitude}")
  end

  def Location.by_distance_from(l)
    order("ST_Distance(#{Location.quoted_table_column(:point)}, ST_GeomFromText('POINT(#{l.longitude} #{l.latitude})', 4326))")
  end

  def Location.distance_spheroid(l)
    dist_q = %{ST_Distance_Spheroid( "locations"."point", ST_GeomFromText('POINT(#{l.longitude} #{l.latitude})', 4326), 'SPHEROID["WGS 84",6378137,298.257223563]')}
    where(" #{dist_q}  < 500")
  end
  
  def Location.us_states
    @US_STATES ||= us_states_select_collection.map(&:first)
  end

  def Location.us_state_codes
    @US_STATE_CODES ||= us_states_select_collection.map(&:last)
  end

  def Location.us_states_select_collection
      [
        ['Alabama', 'AL'],
        ['Alaska', 'AK'],
        ['Arizona', 'AZ'],
        ['Arkansas', 'AR'],
        ['California', 'CA'],
        ['Colorado', 'CO'],
        ['Connecticut', 'CT'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Florida', 'FL'],
        ['Georgia', 'GA'],
        ['Hawaii', 'HI'],
        ['Idaho', 'ID'],
        ['Illinois', 'IL'],
        ['Indiana', 'IN'],
        ['Iowa', 'IA'],
        ['Kansas', 'KS'],
        ['Kentucky', 'KY'],
        ['Louisiana', 'LA'],
        ['Maine', 'ME'],
        ['Maryland', 'MD'],
        ['Massachusetts', 'MA'],
        ['Michigan', 'MI'],
        ['Minnesota', 'MN'],
        ['Mississippi', 'MS'],
        ['Missouri', 'MO'],
        ['Montana', 'MT'],
        ['Nebraska', 'NE'],
        ['Nevada', 'NV'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New Mexico', 'NM'],
        ['New York', 'NY'],
        ['North Carolina', 'NC'],
        ['North Dakota', 'ND'],
        ['Ohio', 'OH'],
        ['Oklahoma', 'OK'],
        ['Oregon', 'OR'],
        ['Pennsylvania', 'PA'],
        ['Puerto Rico', 'PR'],
        ['Rhode Island', 'RI'],
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
        ['Vermont', 'VT'],
        ['Virginia', 'VA'],
        ['Washington', 'WA'],
        ['West Virginia', 'WV'],
        ['Wisconsin', 'WI'],
        ['Wyoming', 'WY']
      ]
  end
  
  validates :state_code, 
            :inclusion => { :in => Location.us_state_codes, :message => "is not the United States" }, 
            :unless => lambda {|loc| loc.state_code.blank? or (loc.country != 'US' and not loc.country.blank?)}
  validates :country, :inclusion => { :in => ['US'], :message => "is not the United States" }
  
  # replace use of this with find_or_smart_create
  def Location.new_from_address(address)
    l = Location.new
    l.address = address
    l.geocode
    l.reverse_geocode
    l
  end
  
  def Location.assign_locations_in_state_to_hood(hood)
    Location.where(:state_code => hood.state).each do |loc|
      loc.send(:lookup_neighborhood)
      loc.save if loc.neighborhood === hood
    end    
  end

  def lookup_and_set_neighborhood
    self.neighborhood = Neighborhood.find_by_lat_lon(self.latitude, self.longitude)
    self.save
  end
  
  def address_contains_city_state
    not self.address.match(/(#{self.city}).+(#{self.state_code})/i).nil?
  end

  protected
  
  def address_or_sythesized_address
    self.address || "#{self.street}#{',' unless self.street.blank?} #{self.city}, #{self.state_code} #{self.zip}".strip
  end
  
  def lookup_time_zone
    unless self.latitude.blank? or self.longitude.blank?
      tz_lookup_result = GoogleTimezone.fetch(self.latitude, self.longitude)
      if tz_lookup_result.success?
        self.time_zone = tz_lookup_result.time_zone_id
      end
    end
  end
  
  def lookup_neighborhood
    unless self.street.blank?
      self.neighborhood = Neighborhood.find_by_lat_lon(self.latitude, self.longitude)
    end
  end
  
  def update_point_from_lon_lat
    unless self.longitude.blank? or self.latitude.blank?
      ActiveRecord::Base.connection.execute(%{
        UPDATE "locations" SET "updated_at" = '#{Time.now}', "point" = ST_GeomFromText('POINT(#{self.longitude} #{self.latitude})', 4326) WHERE "locations"."id" = #{self.id}
      })      
    end
  end
  
end
