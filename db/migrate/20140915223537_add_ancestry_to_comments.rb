class AddAncestryToComments < ActiveRecord::Migration
  def change
    add_column :comments, :ancestry, :string
  end
end
