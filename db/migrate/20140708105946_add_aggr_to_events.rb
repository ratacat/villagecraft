class AddAggrToEvents < ActiveRecord::Migration
  def change
    add_column :events, :aggr, :boolean, default: false
  end
end
