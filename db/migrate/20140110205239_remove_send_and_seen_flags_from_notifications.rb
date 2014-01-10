class RemoveSendAndSeenFlagsFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :sent
    remove_column :notifications, :seen
  end

  def down
    add_column :notifications, :sent, :boolean, :default => false
    add_index :notifications, :sent
    add_column :notifications, :seen, :boolean, :default => false
    add_index :notifications, :seen
  end
end
