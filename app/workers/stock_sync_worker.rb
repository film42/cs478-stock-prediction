class StockSyncWorker
  include ::Sidekiq::Worker

  def perform(stock_symbol)
    batch_download_all_from_yahoo(stock_symbol)
  end

  private

  def batch_download_all_from_yahoo(stock_symbol)
    raw_dataset = ::YahooFinance.historical_quotes(stock_symbol)
    raw_dataset.each do |quote|
      stock_price = StockPrice.where(:label => stock_symbol,
                                     :quote_for => quote.trade_date.to_datetime)
        .first_or_initialize

      stock_price.update_attributes!(:price => quote.adjusted_close)
    end
  end
end
