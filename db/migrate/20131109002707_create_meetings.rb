class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.text :snippet
      t.references :venue

      t.timestamps
    end
    add_index :meetings, :venue_id
  end
end
