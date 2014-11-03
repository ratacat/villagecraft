class AddUuidToEvents < ActiveRecord::Migration
  def change
    add_column :events, :uuid, :string
  end
end
