class AddPriceForColumnToStockPrice < ActiveRecord::Migration
  def change
    add_column :stock_prices, :quote_for, :datetime
  end
end
