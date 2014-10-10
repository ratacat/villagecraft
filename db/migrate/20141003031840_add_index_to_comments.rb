class AddIndexToComments < ActiveRecord::Migration
  def change
    add_index :comments, :uuid
  end
end
