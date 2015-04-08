class SetDefaultTrainingAccuracy < ActiveRecord::Migration
  def change
    remove_column :stock_predictions, :training_accuracy
    add_column :stock_predictions, :training_accuracy, :float, :default => 0, :null => false
  end
end
