class AddUuidsToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :uuid, :string
    add_index :workshops, :uuid
  end
end
