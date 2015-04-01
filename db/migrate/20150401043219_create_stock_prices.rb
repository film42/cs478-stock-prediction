class CreateStockPrices < ActiveRecord::Migration
  def change
    create_table :stock_prices do |t|
      t.string :label
      t.float :price

      t.timestamps null: false
    end
  end
end
