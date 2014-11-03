class AddUuidsToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :uuid, :string
    add_index :meetings, :uuid
  end
end
