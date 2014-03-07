class AddWarmupMessageFieldsToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :warmup_subject, :string
    add_column :workshops, :warmup_body, :text
  end
end
