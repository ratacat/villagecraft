namespace :db do
  desc "Enable Postgris extension"
  task :enable_postgis => :environment do
    begin
      ActiveRecord::Base.connection.execute("CREATE EXTENSION postgis;");
    rescue Exception => e
    end    
  end

  desc "Execute Postgris management functions to set up geospatial features"
  task :postgis_setup => [:enable_postgis] do
    begin
      ActiveRecord::Base.connection.execute("SELECT AddGeometryColumn('public','neighborhoods','geom',4326,'MULTIPOLYGON',2);")
    rescue Exception => e
      # Silently fail if geom column alread exists
    end    
  end
  
  task :seed => [:postgis_setup] do
  end

  task :load_zillow_hoods, [:state] => :environment do |t, args|
    state = args[:state].strip.upcase
    zip_fn = "ZillowNeighborhoods-#{state}.zip"
    dest_fn = Rails.root.join('db', 'neighborhoods', zip_fn)
    tmpdir = File.join('', 'tmp')
    tmp_sql_fn = File.join('', 'tmp', "#{state}.sql")
    
    `curl http://www.zillow.com/static/shp/#{zip_fn} -o #{dest_fn}` unless File.exist?(dest_fn)
    `unzip -o #{dest_fn} -d #{tmpdir}`
    `shp2pgsql -s 4269:4326 -a #{"/tmp/ZillowNeighborhoods-#{state}.shp"} public.neighborhoods > #{tmp_sql_fn}`
    
    db_config = ActiveRecord::Base.configurations[Rails.env]
    host = db_config["host"]
    db = db_config["database"]
    username = db_config["username"]
    password = db_config["password"]
    `psql -d "#{db}" -f #{tmp_sql_fn} #{username}`
    
    # Force neighborhood lookup for all locations in state whose neighborhoods have been newly imported
    Location.where(:state_code => state).each do |loc|
      loc.save
    end
  end
  
  desc "Import hand-drawn neighborhood boundaries (such as can be drawn with this tool: http://www.birdtheme.org/useful/googletool.html); note: the <Placemark><name> will become the neighborhood name"
  # E.g. rake db:load_kml_neighborhood[db/neighborhoods/north_berkeley.kml]
  task :load_kml_neighborhood, [:fn] => :environment do |t, args|
    kml_fn = args[:fn].strip
    
#    db_config = Rails.application.config.database_configuration[Rails.env]
    db_config = ActiveRecord::Base.configurations[Rails.env]
    host = db_config["host"]
    db = db_config["database"]
    username = db_config["username"]
    password = db_config["password"]
    ogr2ogr_options = '-append -nlt MULTIPOLYGON -nln neighborhoods -f "PostgreSQL"'
    gdal_data_path = Rails.env.development? ? "/Applications/Postgres.app/Contents/MacOS/share/gdal" : '/usr/share/gdal'
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
  
  task :load_kml_neighborhoods => :environment do
    kmls = Rails.root.join('db', 'neighborhoods', '*.kml')
    Dir.glob(kmls).each do |fn|
      Rake::Task['db:load_kml_neighborhood'].reenable
      Rake::Task['db:load_kml_neighborhood'].invoke(fn)
    end
  end

end
