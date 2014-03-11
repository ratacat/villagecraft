class AddSentAtToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sent_at, :datetime
    add_index :messages, :sent_at
  end
end
