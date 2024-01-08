namespace :api_data_fetcher do
  desc "Retrieve data from Binance"
  task fetch_data: :environment do

    def fetch(symbol, date, interval)
      unix_starttime = (Time.parse(date + ' 00:00:00 GMT').to_i)
      unix_endtime = (unix_starttime + 86399) * 1000
      unix_starttime *= 1000
      
      "https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=1500"
    end

    def get_future_symbols
      url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')

      response = Net::HTTP.get(url)
      data = JSON.parse(response)

      array_of_symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }
      array_of_symbols = array_of_symbols.product(['2024/01/07'], ['1m'])

      urls = []

      array_of_symbols.each do |symbol, interval, date|
        url = fetch(symbol, interval, date)
        urls << url
      end

      return urls

    end

    urls = get_future_symbols

    urls.each do |url|
      symbol, interval, unix_starttime = url.match(/symbol=(.*?)&interval=(.*?)&starttime=(\d*)&endtime=(\d*)&limit=1500/).captures
      date = Time.at(unix_starttime.to_i / 1000).strftime('%Y/%m/%d')
      uri = URI(url)

      response = Net::HTTP.get_response(uri)

      content = JSON.parse(response.body)

      BinanceFuturesKline.create(
        symbol: symbol,
        day: date,
        interval: interval,
        content: content
      )
    end

    klines = BinanceFuturesKline.all
  end
end