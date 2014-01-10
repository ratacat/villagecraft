class AddUnlockedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :unlocked_at, :datetime
  end
end
