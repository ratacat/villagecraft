class CreateNeighborhoodsTable < ActiveRecord::Migration
  def up
    create_table :neighborhoods do |t|
      t.string :state, :limit => 2
      t.string :county, :limit => 43
      t.string :city, :limit => 64
      t.string :name, :limit => 64
      t.decimal :regionid
    end
    # This is less than elegant, but combined with config.active_record.schema_format = :sql kind of works.
    # In theory, activerecord-postgis-adapter (https://github.com/dazuma/activerecord-postgis-adapter) extends rails migrations
    # to support PostGIS extensions, but I couldn't get it working.  -- ben
    execute("CREATE EXTENSION postgis;");
    execute("SELECT AddGeometryColumn('public','neighborhoods','geom','0','MULTIPOLYGON',2);")
  end

  def down
    drop_table :neighborhoods
  end
end
