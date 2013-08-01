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
      ActiveRecord::Base.connection.execute("SELECT AddGeometryColumn('public','neighborhoods','geom','0','MULTIPOLYGON',2);")
    rescue Exception => e
    end    
  end
  
  task :seed => [:postgis_setup] do
  end

  task :load_zillow_hoods, :state do |t, args|
    state = args[:state].strip.upcase
    zip_fn = "ZillowNeighborhoods-#{state}.zip"
    dest_fn = Rails.root.join('db', 'neighborhoods', zip_fn)
    tmpdir = File.join('', 'tmp')
    tmp_sql_fn = File.join('', 'tmp', "#{state}.sql")
    
    `curl http://www.zillow.com/static/shp/#{zip_fn} -o #{dest_fn}`
    `unzip -o #{dest_fn} -d #{tmpdir}`
    `shp2pgsql -s 4269 -a #{"/tmp/ZillowNeighborhoods-#{state}.shp"} public.neighborhoods > #{tmp_sql_fn}`
    `psql -d "villagecraft_#{Rails.env}" -f #{tmp_sql_fn}`
  end

end
