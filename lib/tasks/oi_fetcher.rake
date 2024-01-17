namespace :oi_fetcher do
    desc "TODO"
    task :scratch_data, [:symbol] => :environment do |t, args|

    def get_all_symbols
        url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
        response = Net::HTTP.get(url)
        data = JSON.parse(response)
        all_symbols = data['symbols'].select { |data| data['status'] == "TRADING"}.map  { |data| data['symbol']}
        all_symbols
    end
      
    all_symbols = get_all_symbols

    all_intervals = ["5m","15m","30m","1h","2h","4h","6h","12h","1d"]

    queue = Queue.new

    all_symbols.product(all_intervals).each { |item| queue.push(item) }

    end_time = DateTime.now.beginning_of_day.utc
    start_time = end_time - 1.months
  
    workers = []
    worker_count = 6

    raw_records = Queue.new

    workers = []
    worker_count.times do
      workers << Thread.new do
      until queue.empty?
        item = queue.pop
        
        url = URI("https://fapi.binance.com/futures/data/openInterestHist?symbol=#{item[0]}&period=#{item[1]}&starttime=#{start_time}endtime=#{end_time}&limit=500")

        response = Net::HTTP.get(url)
        content = JSON.parse(response)
        puts "worker: #{item[0]} #{item[1]}"

        raw_records << [item[0], start_time.to_date, end_time.to_date, item[1], content]

        sleep(1)
      end
      end
    end

    workers.each(&:join)

    all_entries = []

    all_entries << raw_records.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceOpenInterests.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])
    end

    end
end