class AddPreferredDistanceUnitsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preferred_distance_units, :string, :default => 'mi'
    add_index :users, :preferred_distance_units
  end
end
