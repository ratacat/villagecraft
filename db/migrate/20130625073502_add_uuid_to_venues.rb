class AddUuidToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :uuid, :string
  end
end
