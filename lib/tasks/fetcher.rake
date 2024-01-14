namespace :fetcher do
  desc "TODO"
  task :scratch_1m, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    interval = '1m'

    initial_date_time = DateTime.parse('2024-01-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = date_time.beginning_of_day.to_i * 1e3.to_i

      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 7

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
        date_time = initial_date_time - i.days

        loop do
          url = generate_url(symbol, interval, date_time)

          response = Net::HTTP.get(url)

          content = JSON.parse(response)

          if content.empty?
            break
          end

          puts "Worker #{i}: #{date_time} #{url}:#{content}"

          queue.push [symbol, date_time.to_date, interval, content]

          date_time = date_time - worker_count.day

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

  task :scratch_3m, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    interval = '3m'

    initial_date_time = DateTime.parse('2024-01-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = (date_time.beginning_of_day.to_i - 3.days.to_i) * 1e3.to_i
      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 7

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
        date_time = initial_date_time - (i * 3).days

        loop do
          url = generate_url(symbol, interval, date_time)

          response = Net::HTTP.get(url)

          content = JSON.parse(response)

          if content.empty?
            break
          end

          puts "Worker #{i}: #{date_time} #{url}:#{content}"

          queue.push [symbol, date_time.to_date, interval, content]

          date_time = date_time - (3 * worker_count).days

          sleep(1)
        end
      end
    end

    workers.each(&:join)

    entries = []

    entries << queue.pop until queue.empty?

    entries = entries.map { |symbol, day, interval, content| { symbol: symbol, day: day, interval: interval, content: content } }

    BinanceFuturesKlines.insert_all(entries)

  end

  task :scratch_5m, [:symbol] => :environment do |t, args|

    symbol = args[:symbol]

    interval = '5m'

    initial_date_time = DateTime.parse('2024-01-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = (date_time.beginning_of_day.to_i - 5.days.to_i) * 1e3.to_i
      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 7

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
        date_time = initial_date_time - (i * 5).days

        loop do
          url = generate_url(symbol, interval, date_time)

          response = Net::HTTP.get(url)

          content = JSON.parse(response)

          if content.empty?
            break
          end

          puts "Worker #{i}: #{date_time} #{url}:#{content}"

          queue.push [symbol, date_time.to_date, interval, content]

          date_time = date_time - (5 * worker_count).days

          sleep(1)
        end
      end
    end

    workers.each(&:join)

    entries = []

    entries << queue.pop until queue.empty?

    entries = entries.map { |symbol, day, interval, content| { symbol: symbol, day: day, interval: interval, content: content } }

    BinanceFuturesKlines.insert_all(entries)

  end

  task :scratch_15m, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    interval = '15m'

    initial_date_time = DateTime.parse('2020-06-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = (date_time.beginning_of_day.to_i - 15.days.to_i) * 1e3.to_i
      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 7

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
        date_time = initial_date_time - (i * 15).days

        loop do
          url = generate_url(symbol, interval, date_time)

          response = Net::HTTP.get(url)

          content = JSON.parse(response)

          if content.empty?
            break
          end

          puts "Worker #{i}: #{date_time} #{url}:#{content}"

          queue.push [symbol, date_time.to_date, interval, content]

          date_time = date_time - (15 * worker_count).days

          sleep(1)
        end
      end
    end

    workers.each(&:join)

    entries = []

    entries << queue.pop until queue.empty?

    entries = entries.map { |symbol, day, interval, content| { symbol: symbol, day: day, interval: interval, content: content } }

    BinanceFuturesKlines.insert_all(entries)

  end

  task :scratch_monthly, [:symbol] => :environment do |t, args|
    
    symbol = args[:symbol]

    intervals = ["30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]

    initial_date_time = DateTime.parse('2024-01-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = (date_time.beginning_of_day.to_i - 1.month.to_i) * 1e3.to_i
      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 7

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
      intervals.each do |interval| 
        date_time = initial_date_time - i.months
    
        loop do
            url = generate_url(symbol, interval, date_time)
    
            response = Net::HTTP.get(url)
    
            content = JSON.parse(response)
    
            if content.empty?
              break
            end
    
            puts "Worker #{i}: #{date_time} #{interval} #{url}:#{content}"
    
            queue.push [symbol, date_time.to_date, interval, content]
    
          date_time = date_time - worker_count.months
    
          sleep(1)
          end
        end
      end
    end

    workers.each(&:join)

    entries = []

    entries << queue.pop until queue.empty?

    entries = entries.map { |symbol, day, interval, content| { symbol: symbol, day: day, interval: interval, content: content } }

    BinanceFuturesKlines.insert_all(entries)

  end

  desc "Sort klines in database"
  task sort_klines: :environment do
  

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

  desc "Sort out duplicates"
  task filter_data: :environment do


    all_binance_klines = BinanceFuturesKlines.all
    before = all_binance_klines.count.to_i
    all_binance_klines.find_each do |record|
      duplicates = BinanceFuturesKlines.where(content: record.content).where.not(id: record.id)
      duplicates.destroy_all
    end
    new_data = BinanceFuturesKlines.all.count.to_i
    puts "Difference: #{before - new_data}"

  end


end
