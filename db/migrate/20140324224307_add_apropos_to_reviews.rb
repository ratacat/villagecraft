class AddAproposToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :apropos_id, :integer
    add_column :reviews, :apropos_type, :string
    add_index :reviews, :apropos_id
    add_index :reviews, :apropos_type
  end
end
