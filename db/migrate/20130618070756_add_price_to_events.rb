class AddPriceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :price, :decimal, :precision => 10, :scale => 2
  end
end
