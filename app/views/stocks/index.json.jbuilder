json.array!(@stocks) do |stock|
  json.extract! stock, :id, :label
  json.url stock_url(stock, format: :json)
end
