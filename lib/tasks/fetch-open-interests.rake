namespace :oi_data_fetcher do
    desc "Retrieve data from Binance"
    task fetch_open_interests: :environment do

        def fetch(symbol, start_time, end_time, interval)
            unix_starttime = (Time.parse(start_time + ' 00:00:00 GMT').to_i) * 1000
            unix_endtime = ((Time.parse(end_time + ' 00:00:00 GMT').to_i) * 1000) - 1
            
            "https://fapi.binance.com/futures/data/openInterestHist?symbol=#{symbol}&period=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=500"
          end
      
        def get_future_symbols
            all_possible_intervals = ["5m","15m","30m","1h","2h","4h","6h","12h","1d"]
          
            url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
            response = Net::HTTP.get(url)
            data = JSON.parse(response)
            all_symbols = []

            array_of_symbols = data['symbols'].map { |symbol_data| symbol_data['symbol'] }

            end_date = Date.today
            start_date = end_date - 30

            all_possible_intervals.each do |interval|
              array_of_symbols.each do |symbol|
                  formatted_start = start_date.strftime('%Y/%m/%d')
                  formatted_end = end_date.strftime('%Y/%m/%d')
                  all_symbols << [symbol, formatted_start, formatted_end, interval]
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
    
          p url

          sleep(1)
        end
      end
    end

    6.times { combinations_queue << nil }
    threads.each(&:join)

    all_binance_interests = BinanceOpenInterests.all
    interests_records = []

    all_binance_interests.each do |interests_from_binance|
      content_data = interests_from_binance.content

      content_data.each do |interval_data|

        interests_records << {
          symbol: interests_from_binance.symbol,
          day: interests_from_binance.day,
          interval: interests_from_binance.interval,
          content: interval_data
        }
      end
    end

    OpenInterests.insert_all(interests_records)

    end
end