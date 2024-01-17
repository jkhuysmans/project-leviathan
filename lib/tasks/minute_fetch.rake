namespace :minute_fetch do
    desc "TODO"
    task :minute_fetch, [:symbol] => :environment do |t, args|

        def get_all_symbols
            url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
            response = Net::HTTP.get(url)
            data = JSON.parse(response)
            all_symbols = data['symbols'].select { |data| data['status'] == "TRADING"}.map  { |data| data['symbol']}
            all_symbols
          end
      
          all_symbols = get_all_symbols
          all_intervals = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]
      
          worker_count = 6
          queue = Queue.new
          all_symbols.product(all_intervals).each { |item| queue.push(item) }
      
          start_date = DateTime.now.beginning_of_minute
          end_date = start_date.end_of_minute
      
          raw_records = Queue.new
      
          workers = []
          worker_count.times do
            workers << Thread.new do
            until queue.empty?
              item = queue.pop
              
              url = URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{item[0]}&interval=#{item[1]}&starttime=#{start_date.to_i * 1000}&endtime=#{end_date.to_i * 1000}&limit=1500")
              response = Net::HTTP.get(url)
              content = JSON.parse(response)
              p content
      
              raw_records << [item[0], start_date, end_date, item[1], content]
      
              sleep(1)
            end
            end
          end
      
          workers.each(&:join)
      
          all_entries = []
      
          all_entries << raw_records.pop until raw_records.empty?

          all_entries.each do |entry|
            puts entry
          end
      
            #all_entries.each_slice(100) do |entries_slice|
            #entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
            #  { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
            #end
        
            #BinanceFuturesKlines.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])
          #end 
        



    end
end