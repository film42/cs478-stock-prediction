class AddErrorToStockPrediction < ActiveRecord::Migration
  def change
    add_column :stock_predictions, :training_accuracy, :float
  end
end
