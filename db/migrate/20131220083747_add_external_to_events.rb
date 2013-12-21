class AddExternalToEvents < ActiveRecord::Migration
  def change
    add_column :events, :external, :boolean
    add_column :events, :external_url, :string
    add_index :events, :external
  end
end
