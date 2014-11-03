class AddGreetingMessageFieldsToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :greeting_subject, :string
    add_column :workshops, :greeting_body, :text
    add_index :workshops, :greeting_subject
    add_index :workshops, :greeting_body
  end
end
