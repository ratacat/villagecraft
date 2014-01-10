class AddSmsedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :smsed_at, :datetime
    add_index :notifications, :smsed_at
  end
end
