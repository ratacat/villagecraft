class SetDefaultValuesForMinMaxInEvents < ActiveRecord::Migration
  def self.up
    change_column :events, :min_attendees, :integer, :default => 3
    change_column :events, :max_attendees, :integer, :default => 8
  end

  def self.down
    # You can't currently remove default values in Rails
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end


class SetDefault < ActiveRecord::Migration
end