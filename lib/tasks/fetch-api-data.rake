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
      all_possible_intervals = ['1m']

      url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
      all_symbols = []

      all_possible_intervals.each do |interval|
        array_of_symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }
        array_of_symbols = array_of_symbols.product(['2023/12/07'], [interval])
        all_symbols.concat(array_of_symbols)
      end
      all_symbols
    end 

    symbols_with_intervals = get_future_symbols
    
    combinations_queue = Queue.new
    symbols_with_intervals.each { |combination| combinations_queue << combination }
    
    threads = []
    2.times do
      threads << Thread.new do
        loop do
          combination = combinations_queue.pop
          break if combination.nil?
    
          symbol, date, interval = combination
          url = fetch(symbol, date, interval) 
    
          uri = URI(url)

          response = Net::HTTP.get_response(uri)

          content = JSON.parse(response.body)

          BinanceFuturesKlines.create(
            symbol: symbol,
            day: date,
            interval: interval,
            content: content
          )

          sleep(1)
        end
      end

    end
    
    8.times { combinations_queue << nil }
    threads.each(&:join)


    all_binance_klines = BinanceFuturesKlines.all
    kline_records = []

    all_binance_klines.each do |klines_from_binance|
      content_data = klines_from_binance.content

      content_data.each do |interval_data|

        kline_records << {
          symbol: klines_from_binance.symbol,
          day: klines_from_binance.day,
          interval: klines_from_binance.interval,
          content: interval_data
        }
      end
    end

    Kline.insert_all(kline_records)

    
  end
end