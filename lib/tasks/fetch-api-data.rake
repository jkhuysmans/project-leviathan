namespace :api_data_fetcher do
  desc "Retrieve data from Binance"
  task fetch_data: :environment do

    @no_more_data = false

    def fetch(symbol, date, interval)
      unix_starttime = (Time.parse(date + ' 00:00:00 GMT').to_i)
      unix_endtime = (unix_starttime + 2591999) * 1000
      unix_starttime *= 1000
      
      "https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=1500"
    end

    def get_future_symbols
      all_possible_intervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M']
    
      url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
      all_symbols = []
    
      array_of_symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }
    
      start_date = Date.parse('2023-12-01')

      while start_date >= Date.parse('2023-01-01')
        end_date = start_date.next_month.prev_day

        all_possible_intervals.each do |interval|
          case interval
          when '1m', '3m', '5m', '15m'
            (start_date..end_date).each do |date|
              formatted_date = date.strftime('%Y/%m/%d')
              array_of_symbols.each do |symbol|
                all_symbols << [symbol, formatted_date, interval]
              end
            end
          else
            formatted_start_date = start_date.strftime('%Y/%m/%d')
            formatted_end_date = end_date.strftime('%Y/%m/%d')
            array_of_symbols.each do |symbol|
              all_symbols << [symbol, formatted_start_date, interval]
            end
          end
        end
    
        start_date = start_date.prev_month
      end

      all_symbols
    end

    symbols_with_intervals = get_future_symbols
    p symbols_with_intervals
    
    combinations_queue = Queue.new
    symbols_with_intervals.each { |combination| combinations_queue << combination }
    
    threads = []
    6.times do
      threads << Thread.new do
        loop do
          combination = combinations_queue.pop
          break if combination.nil?
    
          symbol, date, interval = combination
          url = fetch(symbol, date, interval) 
    
          uri = URI(url)

          response = Net::HTTP.get_response(uri)

          content = JSON.parse(response.body)

          @no_more_data = false if content.empty?

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