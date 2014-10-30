class AddReminderFieldToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :reminder, :string
  end
end
