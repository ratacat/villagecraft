class DefaultSmsShortMessagesFlagToTrueInUsers < ActiveRecord::Migration
  def up
    change_column :users, :sms_short_messages, :boolean, :default => true
  end

  def down
    change_column :users, :sms_short_messages, :boolean
  end
end
