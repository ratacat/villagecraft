class AddMessagesTable < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :uuid
      t.string :subject
      t.text :body
      t.references :from_user
      t.references :to_user
      t.integer :apropos_id
      t.string :apropos_type
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :messages, :uuid
    add_index :messages, :from_user_id
    add_index :messages, :to_user_id
    add_index :messages, :apropos_id
    add_index :messages, :apropos_type
    add_index :messages, :deleted_at
  end
end
