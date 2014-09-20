class AddAmountAndFeeCollectedToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :amount, :integer
    add_column :charges, :fee_collected, :integer
  end
end
