class AddSendWarmupAtToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :send_warmup_at, :datetime
    add_index :meetings, :send_warmup_at
    
    add_column :meetings, :sent_warmup_at, :datetime
    add_index :meetings, :sent_warmup_at
  end
end
