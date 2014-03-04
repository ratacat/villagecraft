class AddAttachmentIToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :i
    end
  end

  def self.down
    drop_attached_file :images, :i
  end
end
