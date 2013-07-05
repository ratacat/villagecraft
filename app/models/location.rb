class Location < ActiveRecord::Base
  attr_accessible :name, :city, :state_code, :street, :address
  has_many :venues
  
  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.street = geo.street_address
      obj.city = geo.city
      obj.state = geo.state
      obj.state_code = geo.state_code
      obj.zip = geo.postal_code
      obj.country = geo.country_code
    end
  end
  before_validation :sythesize_address
  after_validation :geocode, :lookup_time_zone
  
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
  
  validates :state_code, :inclusion => { :in => Location.us_state_codes, :message => "is not the United States" }
  
  protected
  
  def sythesize_address
    self.address = "#{self.street}#{',' unless self.street.blank?} #{self.city}, #{self.state_code} #{self.zip}".strip
  end
  
  def lookup_time_zone
    tz_lookup_result = GoogleTimezone.fetch(self.latitude, self.longitude)
    if tz_lookup_result.success?
      self.time_zone = tz_lookup_result.time_zone_id
    end
  end
  
end
