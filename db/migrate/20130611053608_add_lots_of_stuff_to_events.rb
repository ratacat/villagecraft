class AddLotsOfStuffToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.remove :user_id
      t.remove :datetime
      t.remove :location
      t.remove :attendance_type
      t.remove :group_size
      
      t.references :course
      t.references :host
      t.references :location
      t.integer :min_attendees
      t.integer :max_attendees
      t.boolean :open
      t.integer :max_observers
      t.datetime :start_time
      t.datetime :end_time
      t.string :secret
      t.string :short_title
    end
    change_column :events, :description, :text
    
  end

  def self.down
    change_table :events do |t|
      t.references :user
      t.datetime :datetime
      t.string :location
      t.string :attendance_type
      t.integer :group_size

      t.remove :course_id      
      t.remove :host_id
      t.remove :location_id
      t.remove :min_attendees
      t.remove :max_attendees
      t.remove :open
      t.remove :max_observers
      t.remove :start_time
      t.remove :end_time
      t.remove :secret
      t.remove :short_title
    end
    add_index :events, :user_id
    change_column :events, :description, :string

  end
end
