class AddCommentableTypeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :commentable_type, :string
  end
end
