class AddCommentableIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :commentable_id, :integer
  end
end
