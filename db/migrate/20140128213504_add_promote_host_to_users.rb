class AddPromoteHostToUsers < ActiveRecord::Migration
  def change
    add_column :users, :promote_host, :boolean
  end
end
