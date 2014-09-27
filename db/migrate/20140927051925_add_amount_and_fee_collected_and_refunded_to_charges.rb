class AddAmountAndFeeCollectedAndRefundedToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :amount, :integer
    add_column :charges, :fee_collected, :integer
    add_column :charges, :refunded, :boolean, default: false
  end
end
