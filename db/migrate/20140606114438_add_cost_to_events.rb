class AddCostToEvents < ActiveRecord::Migration
  def up
    add_column :events, :cost_type, :string
    add_column :events, :end_price, :decimal, :precision => 10, :scale => 2

    Event.all.each do |event|
      if event.price.blank? or event.price == 0
        event.update_attribute(:cost_type, :free)
      else
        event.update_attribute(:cost_type, :set_price)
      end
    end
  end

  def down
    remove_column :events, :cost_type, :string
    remove_column :events, :end_price, :decimal, :precision => 10, :scale => 2
  end
end
