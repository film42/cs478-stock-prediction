class StockPrice < ActiveRecord::Base
  def self.last_2_weeks_chartable
    price_points = self.where('quote_for >= ?', 2.weeks.ago).group_by(&:label)

    price_points.inject({}) do |acc, (symbol, points)|
      acc[symbol] = build_chart(points).sort_by { |v| v.first }
      acc
    end
  end

  def self.last_4_weeks_chartable
    price_points = self.where('quote_for >= ?', 4.weeks.ago).group_by(&:label)

    price_points.inject({}) do |acc, (symbol, points)|
      acc[symbol] = build_chart(points).sort_by { |v| v.first }
      acc
    end
  end

  private

  def self.build_chart(points)
    dates = points.map(&:quote_for).map { |dt| dt.to_date.strftime("%m-%d") }
    prices = points.map(&:price)
    dates.zip(prices)
  end
end
