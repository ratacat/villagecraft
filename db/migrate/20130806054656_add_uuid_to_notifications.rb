class AddUuidToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :uuid, :string
  end
end
