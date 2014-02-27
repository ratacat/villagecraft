class AddRatingAndTitleAndEventIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :rating, :integer, :default => 0
    add_column :reviews, :title, :string, :limit => 160
    remove_column :reviews, :workshop_id
    add_column :reviews, :event_id, :integer
  end

end
