class AddNeighborhoodToLocation < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.references :neighborhood
    end
    add_index :locations, :neighborhood_id
    
  end

  def self.down
    change_table :locations do |t|
      t.remove :neighborhood_id
    end
  end
end
