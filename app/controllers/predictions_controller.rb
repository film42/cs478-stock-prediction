class PredictionsController < ApplicationController
  def index
    @predictions = StockPrediction.all_predictions
    @training_accuracies = StockPrediction.training_accuracies
    @historical_quotes = StockPrice.last_2_weeks_chartable
  end
end
