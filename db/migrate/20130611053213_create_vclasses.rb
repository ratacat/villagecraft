class CreateVclasses < ActiveRecord::Migration
  def change
    create_table :vclasses do |t|
      t.references :admin

      t.timestamps
    end
    add_index :vclasses, :admin_id
  end
end
