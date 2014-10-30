class AddProfileImageToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :profile_image
    end
    add_index :users, :profile_image_id
    
  end

  def self.down
    change_table :users do |t|
      t.remove :profile_image_id
    end
  end
end
