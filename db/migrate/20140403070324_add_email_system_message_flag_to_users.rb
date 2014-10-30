class AddEmailSystemMessageFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_system_messages, :boolean, :default => true
  end
end
