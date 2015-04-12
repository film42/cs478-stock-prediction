class StockPredictorKnnWorker
  include ::Sidekiq::Worker

  PATTERN_LENGTH = 5
  DAYS_TO_PREDICT = 7
  LOOK_BACK = 500 # Days
  K = 5

  def perform(stock_symbol)
    # This is not good; We need a better queue
    logger.info "Syncing stock symbol: #{stock_symbol}"
    StockSyncWorker.new.perform(stock_symbol)

    @stock_symbol = stock_symbol
    logger.info "Predicting with kNN for stock symbol: #{stock_symbol}"
    train_knn!
    error = calculate_mse

    logger.info("New error for #{stock_symbol}: #{error}")

    results =  predict_n_days(DAYS_TO_PREDICT)

    results.each_with_index do |price, index|
      prediction_date = index.days.from_now.midnight
      prediction = ::StockPrediction.where(:label => stock_symbol,
                                           :learned_with => :knn,
                                           :prediction_for => prediction_date).first_or_initialize

      prediction.update_attributes!(:price => price, :training_accuracy => error)
    end
  end

  private

  attr_reader :stock_symbol, :knn

  def predict_n_days(n_days)
    predicted_days = []
    most_current_sequence = dataset.first
    (0...n_days).map do |day|
      feature_row = most_current_sequence

      logger.info "Running with feature row: #{feature_row.inspect}"

      index, _, _ = knn.nearest_neighbours(feature_row, K)[1]

      if index > 0
        predicted_value = dataset[index - 1].first
        most_current_sequence.append(predicted_value)
      else
        logger.info "Warning, prediction skipped!"
      end
    end

    predicted_days
  end

  def dataset
    @dataset ||= begin
      raw_data = StockPrice.where(:label => stock_symbol).limit(LOOK_BACK).map(&:price)
      (0...(raw_data.size - PATTERN_LENGTH)).map { |index| raw_data[0...PATTERN_LENGTH] }
    end
  end

  def train_knn!
    @knn ||= ::KNN.new(dataset)
  end

  def calculate_mse
    dataset_size = dataset.size
    distance_error = 0.0
    dataset.each do |row|
      results = knn.nearest_neighbours(row, K)
      _, distance, _ = results[1]
      distance_error += (distance ** 2)
    end

    distance_error / dataset_size.to_f
  end
end
