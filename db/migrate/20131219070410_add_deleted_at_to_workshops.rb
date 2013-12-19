class AddDeletedAtToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :deleted_at, :datetime
    add_index :workshops, :deleted_at
  end
end
