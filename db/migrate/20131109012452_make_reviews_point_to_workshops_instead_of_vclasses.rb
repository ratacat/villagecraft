class MakeReviewsPointToWorkshopsInsteadOfVclasses < ActiveRecord::Migration
  def change
    rename_column :reviews, :vclass_id, :workshop_id
  end
end
