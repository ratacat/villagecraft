class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.references :vclass

      t.timestamps
    end
    add_index :courses, :vclass_id
  end
end
