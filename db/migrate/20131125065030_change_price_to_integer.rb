class ChangePriceToInteger < ActiveRecord::Migration
  def up
    change_column :events, :price, :integer
  end

  def down
    change_column :events, :price, :decimal, :precision => 10, :scale => 2
  end
end
