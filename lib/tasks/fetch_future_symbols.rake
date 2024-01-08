namespace :fetch_future_symbols do
  desc "Fetches all Binance future symbols and returns them into an array"
  task binance_symbols: :environment do

    url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    array_of_symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }
    array_of_symbols = array_of_symbols.product(['2024-01-01'], ['1m'])

    p array_of_symbols
    p array_of_symbols.length

  end

end
