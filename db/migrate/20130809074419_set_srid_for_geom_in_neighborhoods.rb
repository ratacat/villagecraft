class SetSridForGeomInNeighborhoods < ActiveRecord::Migration
  def up
    remove_column :neighborhoods, :geom
    execute("SELECT AddGeometryColumn('public','neighborhoods','geom',4326,'MULTIPOLYGON',2);")
  end

  def down
    remove_column :neighborhoods, :geom
    execute("SELECT AddGeometryColumn('public','neighborhoods','geom','0','MULTIPOLYGON',2);")
  end
end
