class AddIndexToEventsUsersToConstrainUniqueness < ActiveRecord::Migration
  def change
    add_index :events_users, [ :event_id, :user_id ], :unique => true, :name => "index_events_users_on_event_id_and_user_id"
  end
end
