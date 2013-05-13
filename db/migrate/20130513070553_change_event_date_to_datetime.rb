class ChangeEventDateToDatetime < ActiveRecord::Migration
  def up
    change_column :events, :date, :datetime
    rename_column :events, :date, :datetime
  end

  def down
    change_column :events, :date, :date
    rename_column :events, :datetime, :date
  end
end
