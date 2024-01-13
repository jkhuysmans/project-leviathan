namespace :api_data_fetcher do
  desc "Retrieve data from Binance"
  task fetch_data: :environment do

    def fetch(symbol, start_time, end_time, interval)
      unix_starttime = (Time.parse(start_time + ' 00:00:00 GMT').to_i) * 1000
      unix_endtime = ((Time.parse(end_time + ' 00:00:00 GMT').to_i) * 1000) - 1
      
      "https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=1500"
    end

    def get_future_symbols
      all_possible_intervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M']
    
      url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
      all_symbols = []
      onboard = []
    
      symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }
      onboard = data['symbols'].map do |onboard_data|
        timestamp = onboard_data['onboardDate']
        one_date = Time.at(timestamp / 1000).to_date.strftime('%Y/%m/%d')
        Date.parse(one_date)
      end
      array_of_symbols = symbols.zip(onboard)

      array_of_symbols.each do |symbol, earliest_date|
        start_date = Date.parse('2023-12-01')
    
        while start_date >= earliest_date
          end_date = start_date.next_month.prev_day
    
          all_possible_intervals.each do |interval|
            case interval
            when '1m', '3m', '5m', '15m'
              (start_date..end_date).each do |date|
                formatted_start = date.strftime('%Y/%m/%d')
                next_day = date + 1
                formatted_end = next_day.strftime('%Y/%m/%d')
                all_symbols << [symbol, formatted_start, formatted_end, interval]
              end
            else
              formatted_start = start_date.strftime('%Y/%m/%d')
              next_month = start_date >> 1
              formatted_end = next_month.strftime('%Y/%m/%d')
              all_symbols << [symbol, formatted_start, formatted_end, interval]
            end
          end
    
          start_date = start_date.prev_month
        end
      end

      all_symbols

    end

    symbols_with_intervals = get_future_symbols

    combinations_queue = Queue.new
    symbols_with_intervals.each { |combination| combinations_queue << combination }
    
    threads = []
    6.times do
      threads << Thread.new do
        loop do
          combination = combinations_queue.pop
          break if combination.nil?
    
          symbol, start_time, end_time, interval = combination
          url = fetch(symbol, start_time, end_time, interval) 
    
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
    
    6.times { combinations_queue << nil }
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