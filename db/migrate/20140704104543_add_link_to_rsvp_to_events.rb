class AddLinkToRsvpToEvents < ActiveRecord::Migration
  def change
    add_column :events, :link_to_rsvp, :string
  end
end
