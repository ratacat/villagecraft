class AddDeletedAtToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :deleted_at, :datetime
    add_index :venues, :deleted_at
  end
end
