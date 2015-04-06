class KickoffWorker
  include ::Sidekiq::Worker

  def perform(stock_symbol=nil)
    stocks = Stock.where(:label => stock_symbol) unless stock_symbol.nil?
    stocks = Stock.all unless stocks.present?

    stocks.each do |stock|
      logger.info "Kicking off stock sync / prediction worker for #{stock.label}"
      ::StockPredictorWorker.perform_async(stock.label)
    end
  end
end
