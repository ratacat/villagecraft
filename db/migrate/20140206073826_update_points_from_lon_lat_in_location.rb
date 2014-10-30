class UpdatePointsFromLonLatInLocation < ActiveRecord::Migration
  def up
    Location.find_each {|l| l.send(:update_point_from_lon_lat)}
  end

  def down
    Location.find_each {|l| l.update_attribute(:point, nil)}
  end
end
