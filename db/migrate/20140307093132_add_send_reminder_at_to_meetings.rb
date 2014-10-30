class AddSendReminderAtToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :send_reminder_at, :datetime
    add_index :meetings, :send_reminder_at
    
    add_column :meetings, :sent_reminder_at, :datetime
    add_index :meetings, :sent_reminder_at    
  end
end
