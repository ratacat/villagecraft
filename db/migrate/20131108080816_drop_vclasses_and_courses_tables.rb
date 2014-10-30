class DropVclassesAndCoursesTables < ActiveRecord::Migration
  def up
    drop_table :vclasses
    drop_table :courses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
