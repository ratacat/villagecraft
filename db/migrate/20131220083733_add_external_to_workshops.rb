class AddExternalToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :external, :boolean
    add_column :workshops, :external_url, :string
    add_index :workshops, :external
  end
end
