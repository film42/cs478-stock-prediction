class StockPredictorWorker
  include ::Sidekiq::Worker

  PATTERN_LENGTH = 11
  DAYS_TO_PREDICT = 7
  LOOK_BACK = 500 # Days

  def perform(stock_symbol)
    # This is not good; We need a better queue
    logger.info "Syncing stock symbol: #{stock.label}"
    StockSyncWorker.new.perform(stock.label)

    @stock_symbol = stock_symbol
    logger.info "Predicting for stock symbol: #{stock_symbol}"
    ann = train_nueral_network
    results =  predict_n_days(DAYS_TO_PREDICT, ann)

    results.each_with_index do |price, index|
      prediction_date = (index + 1).days.from_now.midnight
      prediction = ::StockPrediction.where(:label => stock_symbol,
                                           :prediction_for => prediction_date).first_or_initialize

      prediction.update_attributes!(:price => price)
    end
  end

  private

  attr_reader :stock_symbol

  def predict_n_days(n_days, ann)
    predicted_days = []
    most_current_sequence = dataset.first
    (0...n_days).map do |day|
      feature_row = most_current_sequence.reverse.take(PATTERN_LENGTH - 1).reverse

      logger.info "Running with feature row: #{feature_row.inspect}"

      predicted_value = ann.run(feature_row).try(:first)
      most_current_sequence.append(predicted_value)
      predicted_days.append(predicted_value)
    end

    predicted_days
  end

  def dataset
    @dataset ||= begin
      raw_data = StockPrice.where(:label => stock_symbol).limit(LOOK_BACK).map(&:price)
      (0...(raw_data.size - PATTERN_LENGTH)).map { |index| raw_data[0...PATTERN_LENGTH] }
    end
  end

  def training_data
    @trainin_data ||= begin
      inputs = []
      outputs = []
      dataset.map do |row|
        input_row = row[0..(row.size - 2)]
        output_row = [row.last]

        inputs.append(input_row)
        outputs.append(output_row)
      end

      [inputs, outputs]
    end
  end

  def train_nueral_network
    inputs, outputs = training_data
    feature_length = inputs.first.size

    fail "No data to train with for symbol: #{stock_symbol}" if inputs.empty?

    train = ::RubyFann::TrainData.new(:inputs => inputs, :desired_outputs => outputs)
    fann = ::RubyFann::Standard.new(:num_inputs => feature_length,
                                    :hidden_neurons => [80],
                                    :num_outputs => 1)
    fann.set_activation_function_hidden(:linear)
    fann.set_activation_function_output(:linear)
    fann.train_on_data(train, 5000, 100, 0.3)
    fann
  end
end
