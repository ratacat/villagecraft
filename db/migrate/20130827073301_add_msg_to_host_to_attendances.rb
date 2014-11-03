class AddMsgToHostToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :message, :text
  end
end
