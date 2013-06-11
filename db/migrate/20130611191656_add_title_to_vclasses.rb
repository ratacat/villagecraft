class AddTitleToVclasses < ActiveRecord::Migration
  def change
    add_column :vclasses, :title, :string
  end
end
