class RemoveEventIdFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :event_id
  end

  def down
    add_column :comments, :event_id, :integer
  end
end
