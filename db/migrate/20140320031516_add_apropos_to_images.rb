class AddAproposToImages < ActiveRecord::Migration
  def change
    add_column :images, :apropos_id, :integer
    add_column :images, :apropos_type, :string
    add_index :images, :apropos_id
    add_index :images, :apropos_type
  end
end
