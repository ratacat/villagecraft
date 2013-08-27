class RemoveConfirmedFromAttendances < ActiveRecord::Migration
  def up
    remove_column :attendances, :confirmed
  end

  def down
    add_column :attendances, :confirmed, :boolean
    add_index :attendances, :confirmed
  end
end
