namespace :daily_fetcher do
    desc "TODO"
    task :scratch_1m, [:symbol] => :environment do |t, args|
      
      symbol = args[:symbol]
  
      interval = '1m'
  
      initial_date_time = DateTime.now.utc
  
      def generate_url(symbol, interval, date_time)
        start_time = date_time.beginning_of_day.to_i * 1e3.to_i
  
        end_time = date_time.end_of_day.to_i * 1e3.to_i
  
        URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
      end
  
      workers = []
  
      worker_count = 6
  
      queue = Queue.new
  
      worker_count.times do |i|
        workers << Thread.new do
          date_time = initial_date_time
      
          url = generate_url(symbol, interval, date_time)
      
          response = Net::HTTP.get(url)
      
          content = JSON.parse(response)
      
          unless content.empty?
            puts "Worker #{i}: #{date_time} #{url}:#{content}"
      
            queue.push [symbol, date_time.to_date, interval, content]
          end
        end
      end
  
      workers.each(&:join)
  
      all_entries = []
  
      all_entries << queue.pop until queue.empty?
  
      all_entries.each_slice(100) do |entries_slice|
        entries = entries_slice.map do |symbol, day, interval, content|
          { symbol: symbol, day: day, interval: interval, content: content }
        end
      
        BinanceFuturesKlines.insert_all(entries)
      end
  
    end




end