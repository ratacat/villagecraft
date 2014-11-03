class RemoveImgAttachmentFieldsFromImages < ActiveRecord::Migration
  def self.up
    drop_attached_file :images, :img
  end

  def self.down
    change_table :images do |t|
      t.attachment :img
    end
  end
end
