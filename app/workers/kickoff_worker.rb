class KickoffWorker
  include ::Sidekiq::Worker

  def perform(stock_symbol=nil)
    stocks = Stock.where(:label => stock_symbol) unless stock_symbol.nil?
    stocks = Stock.all unless stocks.present?

    stocks.each do |stock|
      # This is not good; We need a better queue
      logger.info "Syncing stock symbol: #{stock.label}"
      StockSyncWorker.new.perform(stock.label)
      logger.info "Kicking off stock prediction worker for #{stock.label}"
      StockPredictorWorker.perform_async(stock.label)
    end
  end
end
