class CreateStockPredictions < ActiveRecord::Migration
  def change
    create_table :stock_predictions do |t|
      t.string :label
      t.date :prediction_for
      t.float :price

      t.timestamps null: false
    end
  end
end
