class AddSmsShortMessagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_short_messages, :boolean, :deafult => true
    add_index :users, :sms_short_messages
  end
end
