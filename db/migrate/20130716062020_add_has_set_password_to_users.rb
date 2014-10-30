class AddHasSetPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_set_password, :boolean, :default => true
  end
end
