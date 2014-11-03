class AddSmsMeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sms_me, :boolean
    add_index :notifications, :sms_me
  end
end
