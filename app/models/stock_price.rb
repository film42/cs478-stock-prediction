class StockPrice < ActiveRecord::Base
  def self.last_2_weeks_chartable
    price_points = self.where('quote_for >= ?', 14.days.ago).group_by(&:label)

    price_points.inject({}) do |acc, (symbol, points)|
      acc[symbol] = build_chart(points)
      acc
    end
  end

  private

  def self.build_chart(points)
    dates = points.map(&:quote_for).map { |dt| dt.to_date.to_s(:short) }
    prices = points.map(&:price)
    dates.zip(prices)
  end
end
