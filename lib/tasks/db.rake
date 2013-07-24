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

end
