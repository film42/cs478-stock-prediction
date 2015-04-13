class StockPrediction < ActiveRecord::Base
  def self.all_predictions
    all_predictions = self.where('prediction_for >= ?', 30.days.ago)
      .where(:learned_with => :mlp)
      .all
      .sort_by(&:label)
      .group_by(&:label)

    all_predictions.inject({}) do |acc, (symbol, predictions)|
      acc[symbol] = build_chart(predictions).sort_by { |v| v.first }
      acc
    end
  end

  def self.training_accuracies
    data_points = self.where('prediction_for >= ?', DateTime.now.midnight)
      .all
      .group_by(&:label)

    data_points.inject({}) do |acc, (label, models)|
      acc[label] = models.max_by(&:training_accuracy).training_accuracy
      acc[label] = Math.sqrt(acc[label])
      acc
    end
  end

  private

  def self.build_chart(predictions)
    dates = predictions.map(&:prediction_for).map { |dt| dt.to_date.strftime("%m-%d") }
    prices = predictions.map(&:price)
    dates.zip(prices)
  end
end
