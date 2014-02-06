class AddPointToLocations < ActiveRecord::Migration
  def up
    execute %{ SELECT AddGeometryColumn('public','locations','point', 4326, 'POINT', 2) }
    execute %{ CREATE INDEX index_locations_on_point ON locations USING gist (point) }
  end
  
  def down
    remove_column :locations, :point
  end
end
