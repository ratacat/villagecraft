class RemoveEventIdFromReviews < ActiveRecord::Migration
  def up
    remove_column :reviews, :event_id
  end

  def down
    add_column :reviews, :event_id, :integer
  end
end
