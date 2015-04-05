class ChangeStockPredictionToBeDateTime < ActiveRecord::Migration
  def change
    change_column :stock_predictions, :prediction_for, :datetime
  end
end
