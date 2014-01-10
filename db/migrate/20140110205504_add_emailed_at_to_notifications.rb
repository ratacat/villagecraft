class AddEmailedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :emailed_at, :datetime
    add_index :notifications, :emailed_at
  end
end
