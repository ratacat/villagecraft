class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user
      t.references :activity
      t.boolean :seen, :default => false
      t.boolean :sent, :default => false

      t.timestamps
    end
    add_index :notifications, :user_id
    add_index :notifications, :activity_id
  end
end
