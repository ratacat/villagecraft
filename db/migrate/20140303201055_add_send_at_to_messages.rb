class AddSendAtToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :send_at, :datetime
    add_index :messages, :send_at
  end
end
