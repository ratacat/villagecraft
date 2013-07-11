class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :event
      t.references :user
      t.boolean :confirmed
      t.integer :guests

      t.timestamps
    end
    add_index :attendances, :event_id
    add_index :attendances, :user_id
  end
end
