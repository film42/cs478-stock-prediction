class StockPredictorWorker
  include Sidekiq::Worker

  PATTERN_LENGTH = 11

  def perform(stock_symbol)
    @stock_symbol = stock_symbol
    ann = train_nueral_network
    results = predict_n_days(5, ann)

    results.each_with_index do |price, index|
      stock_prediction = ::StockPrediction.new(
        :label         => stock_symbol,
        :price         => price,
        :prediction_for => (index + 1).days.from_now
      )

      stock_prediction.save!
    end
  end

  private

  attr_reader :stock_symbol

  def predict_n_days(n_days, ann)
    n_days_predicitons = []
    (0...n_days).map do |day|
      previous_n_days = dataset[day..(PATTERN_LENGTH - 1 - n_days_predicitons.size)]
      next_row = previous_n_days + n_days_predicitons
      output = n_days_predicitons.append(next_row)
      n_days_predicitons.append(output)
    end

    n_days_predicitons
  end

  def dataset
    @dataset ||= begin
      raw_data = StockPrice.where(:label => stock_symbol).limit(100).map(&:price)
      (0...(raw_data.size - PATTERN_LENGTH)).map { |index| raw_data[0..PATTERN_LENGTH] }
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
    train = ::RubyFann::TrainData.new(:inputs => inputs, :desired_outputs => outputs)
    fann = ::RubyFann::Standard.new(:num_inputs => 10, :hidden_neurons => [80], :num_outputs => 1)
    fann.set_activation_function_hidden(:linear)
    fann.set_activation_function_output(:linear)
    fann.train_on_data(train, 5000, 100, 0.3)
  end
end
