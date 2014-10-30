class RenameNameFirstToFirstNameAndNameLastToLastName < ActiveRecord::Migration
  def change
    rename_column :users, :name_first, :first_name
    rename_column :users, :name_last, :last_name
  end
end
