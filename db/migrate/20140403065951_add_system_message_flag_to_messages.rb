class AddSystemMessageFlagToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :system_message, :boolean
  end
end
