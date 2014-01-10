class AddEmailMeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :email_me, :boolean
    add_index :notifications, :email_me
  end
end
