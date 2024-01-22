namespace :klines_fetcher do

  task :scratch_daily, [:symbol] => :environment do |t, args|
      
    symbol = args[:symbol]
    
    all_intervals =  ["1m", "3m", "5m", "15m", "30m"]

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
    all_intervals.each do |interval|
      start_time = initial_date_time - i.days

      loop do
        url = generate_url(symbol, interval, start_time)
        end_time = start_time + 1.days 

        response = Net::HTTP.get(url)

        content = JSON.parse(response)

        if content.empty?
          break
        end

        puts "Worker #{i}: #{start_time} #{url}:#{content}"

        queue.push [symbol, start_time.to_date, end_time.to_date, interval, content]

        start_time = start_time - worker_count.day

        sleep(1)
      end
      end
    end
  end

    workers.each(&:join)

    all_entries = []

    all_entries << queue.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
    entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
      { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
    end
  
    BinanceFuturesKlines.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])
  end
end

  task :scratch_monthly, [:symbol] => :environment do |t, args|

    puts "start"
    
    symbol = args[:symbol]

    intervals = ["30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]

    initial_date_time = DateTime.now.utc

    def generate_url(symbol, interval, date_time)
      start_time = (date_time.beginning_of_month).to_i * 1e3.to_i
      end_time = date_time.end_of_month.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 6

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
      intervals.each do |interval| 
        start_time = initial_date_time.beginning_of_month - i.months
    
        loop do
            end_time = (start_time + 1.months) - 1
            url = generate_url(symbol, interval, start_time)
    
            response = Net::HTTP.get(url)
    
            content = JSON.parse(response)
    
            if content.empty?
              break
            end
    
            puts "Worker #{i}: #{start_time} #{interval} #{url}"
    
            queue.push [symbol, start_time.to_date, end_time.to_date, interval, content]
    
          start_time = start_time - worker_count.months
    
          sleep(1)
          end
        end
      end
    end

    workers.each(&:join)

    all_entries = []

    all_entries << queue.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceFuturesKlines.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])
    end

    sql = <<-SQL
      INSERT INTO klines (symbol, day, interval, content, created_at, updated_at)
      SELECT DISTINCT
          symbol,
          day,
          interval,
          value AS content,
          NOW() AS created_at,
          NOW() AS updated_at
      FROM binance_futures_klines, jsonb_array_elements(content)
      ON CONFLICT DO NOTHING;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end