class PredictionsController < ApplicationController
  def index
    @predictions = StockPrediction.all_predictions
    @historical_quotes = StockPrice.last_2_weeks_chartable
  end
end
