class AddAuthColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_provider, :string
    add_column :users, :auth_provider_uid, :string
  end
end
