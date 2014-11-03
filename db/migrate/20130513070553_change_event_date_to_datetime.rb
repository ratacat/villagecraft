class ChangeEventDateToDatetime < ActiveRecord::Migration
  def up
    rename_column :events, :date, :datetime
  end

  def down
    rename_column :events, :datetime, :date
  end
end
