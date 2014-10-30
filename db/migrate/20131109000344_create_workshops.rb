class CreateWorkshops < ActiveRecord::Migration
  def change
    create_table :workshops do |t|
      t.string :title
      t.text :description
      t.string :frequency
      t.references :image
      t.references :host

      t.timestamps
    end
    add_index :workshops, :image_id
    add_index :workshops, :host_id
  end
end
