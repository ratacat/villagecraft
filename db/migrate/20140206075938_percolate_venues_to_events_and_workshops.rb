class PercolateVenuesToEventsAndWorkshops < ActiveRecord::Migration
  def up
    Meeting.order(:start_time).find_each do |meeting|
      meeting.send(:percolate_venue)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot un-percolate"
  end
end
