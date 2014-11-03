class AddUuidToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :uuid, :string, :limit => 255
  end
  add_index :reviews, :event_id
end
