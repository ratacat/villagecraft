class CreateEventsUsers < ActiveRecord::Migration
  def change
    create_table :events_users, :id => false do |t|
      t.references :user
      t.references :event
      t.boolean :confirmed
      t.integer :guests
    end
    add_index :events_users, :user_id
    add_index :events_users, :event_id
  end
end
