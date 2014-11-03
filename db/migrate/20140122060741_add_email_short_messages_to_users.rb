class AddEmailShortMessagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_short_messages, :boolean, :default => false
    add_index :users, :email_short_messages
  end
end
