class RemoveGreetingMessageIndiciesFromWorkshops < ActiveRecord::Migration
  def change
    remove_index :workshops, :greeting_subject
    remove_index :workshops, :greeting_body
  end
end
