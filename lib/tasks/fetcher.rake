namespace :fetcher do
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

    workers.each(&:join)

    all_entries = []

    all_entries << queue.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceFuturesKlines.insert_all(entries)
    end

  end

  task :scratch_3m, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    interval = '3m'

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

  task :scratch_5m, [:symbol] => :environment do |t, args|

    symbol = args[:symbol]

    interval = '5m'

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

    workers.each(&:join)

    all_entries = []

    all_entries << queue.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceFuturesKlines.insert_all(entries)
    end

  end

  task :scratch_15m, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    interval = '15m'

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

    workers.each(&:join)

    all_entries = []

    all_entries << queue.pop until queue.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceFuturesKlines.insert_all(entries)
    end

  end

  task :scratch_monthly, [:symbol] => :environment do |t, args|

    puts "start"
    
    symbol = args[:symbol]

    intervals = ["30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]

    current_month_start = DateTime.now.utc.beginning_of_month
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
    
            puts "Worker #{i}: #{start_time} #{interval} #{url}:#{content}"
    
            queue.push [symbol, start_time, end_time, interval, content]
    
          start_time = start_time - worker_count.months

          break if start_time < current_month_start
    
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

  desc "Sort klines in database"
  task sort_klines: :environment do
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
