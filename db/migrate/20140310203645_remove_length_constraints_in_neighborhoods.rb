class RemoveLengthConstraintsInNeighborhoods < ActiveRecord::Migration
  def up
    change_column :neighborhoods, :county, :string
    change_column :neighborhoods, :city, :string
    change_column :neighborhoods, :name, :string
  end

  def down
    change_column :neighborhoods, :county, :string, :limit => 43
    change_column :neighborhoods, :city, :string, :limit => 64
    change_column :neighborhoods, :name, :string, :limit => 64
  end
end
