class ChangeMinAttendeesDefaultToZero < ActiveRecord::Migration
  def up
    change_column :events, :min_attendees, :integer, :default => 0
  end

  def down
    change_column :events, :min_attendees, :integer, :default => 3
  end
end
