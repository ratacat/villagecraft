class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.references :user
      t.references :event
      t.string :stripe_charge

      t.timestamps
    end
    add_index :charges, :user_id
    add_index :charges, :event_id
    add_index :charges, :stripe_charge
  end
end
