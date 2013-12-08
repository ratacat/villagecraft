class AddFirstMeetingToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.references :first_meeting
    end
    add_index :events, :first_meeting_id
  end

  def self.down
    remove_column :events, :first_meeting_id
  end
end
