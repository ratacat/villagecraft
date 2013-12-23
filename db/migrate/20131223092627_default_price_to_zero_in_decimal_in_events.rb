class DefaultPriceToZeroInDecimalInEvents < ActiveRecord::Migration
  def up
    change_column :events, :price, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def down
    change_column :events, :price, :integer
  end
end
