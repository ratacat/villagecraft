class AddWorkshopToEvents < ActiveRecord::Migration
  def change
    add_column :events, :workshop_id, :integer
    add_index :events, :workshop_id
  end
end
