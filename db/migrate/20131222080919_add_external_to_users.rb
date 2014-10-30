class AddExternalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :external, :boolean
    add_index :users, :external
  end
end
