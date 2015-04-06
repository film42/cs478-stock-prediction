class StockPrediction < ActiveRecord::Base
  def self.all_predictions
    all_predictions = self.where('prediction_for >= ?', DateTime.now.midnight)
      .all
      .sort_by(&:label)
      .group_by(&:label)

    all_predictions.inject({}) do |acc, (symbol, predictions)|
      acc[symbol] = build_chart(predictions)
      acc
    end
  end

  private

  def self.build_chart(predictions)
    dates = predictions.map(&:prediction_for).map { |dt| dt.to_date.to_s(:short) }
    prices = predictions.map(&:price)
    dates.zip(prices)
  end
end
