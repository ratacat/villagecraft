class ChangeConfirmedToHaveDefaultInEventsUsers < ActiveRecord::Migration
  def up
    change_column :events_users, :confirmed, :boolean, :default => false
  end

  def down
    change_column :events_users, :confirmed, :boolean
  end
end
