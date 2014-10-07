class AddUuidsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :uuid, :string
  end
end
