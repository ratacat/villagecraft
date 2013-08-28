class AddUuidToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :uuid, :string
  end
end
