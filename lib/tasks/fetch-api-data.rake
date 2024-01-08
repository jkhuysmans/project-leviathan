namespace :api_data_fetcher do
  desc "Retrieve data from Binance"
  task fetch_data: :environment do
    def fetch(symbol, date, interval)
      unix_starttime = (Time.parse(date + ' 00:00:00 GMT').to_i)
      unix_endtime = (unix_starttime + 86399) * 1000
      unix_starttime *= 1000
      
      "https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=1500"
    end  

    date = '2024-01-07'
    symbol = 'BTCUSDT'
    interval = '1h'

    uri = URI(fetch(symbol, date, interval))

    response = Net::HTTP.get_response(uri)
    content = JSON.parse(response.body)

    BinanceFuturesKline.create(
      symbol: symbol,
      day: date,
      interval: interval,
      content: content
    )

    klines = BinanceFuturesKline.where(symbol: symbol, day: date, interval: interval)
    p klines
  end
end