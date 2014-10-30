class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :vclass
#      t.references :prior_review
      t.references :author
      t.text :body

      t.timestamps
    end
    add_index :reviews, :vclass_id
#    add_index :reviews, :prior_review_id
    add_index :reviews, :author_id
  end
end
