class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.string :location
      t.date :date
      t.string :attendance_type
      t.integer :group_size
      t.timestamps
    end
  end
end
