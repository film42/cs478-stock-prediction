class RenameTypeInStockPrediction < ActiveRecord::Migration
  def change
    rename_column :stock_predictions, :type, :learned_with
  end
end
