class AddInfoLink < ActiveRecord::Migration
  def change
    add_column :events, :info_url, :string
  end

end
