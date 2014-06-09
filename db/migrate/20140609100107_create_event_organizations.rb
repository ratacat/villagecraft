class CreateEventOrganizations < ActiveRecord::Migration
  def change
    create_table :event_organizations do |t|
      t.integer :event_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
