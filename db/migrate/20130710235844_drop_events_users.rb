class DropEventsUsers < ActiveRecord::Migration
  def up
    drop_table :events_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
