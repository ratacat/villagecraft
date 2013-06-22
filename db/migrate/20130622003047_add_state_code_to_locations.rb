class AddStateCodeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :state_code, :string
  end
end
