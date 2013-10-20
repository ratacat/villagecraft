class AddImageIdToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.references :image
    end
    add_index :events, :image_id
    
  end

  def self.down
    change_table :events do |t|
      t.remove :image_id
    end
  end
end
