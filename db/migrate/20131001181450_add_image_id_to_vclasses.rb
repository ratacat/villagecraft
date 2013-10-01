class AddImageIdToVclasses < ActiveRecord::Migration
  def self.up
    change_table :vclasses do |t|
      t.references :image
    end
    add_index :vclasses, :image_id
    
  end

  def self.down
    change_table :vclasses do |t|
      t.remove :image_id
    end
  end
end
