class AddTypeToStockPrediction < ActiveRecord::Migration
  def change
    add_column :stock_predictions, :type, :string
  end
end
