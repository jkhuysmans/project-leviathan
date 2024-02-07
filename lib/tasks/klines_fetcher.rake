namespace :klines_fetcher do
  desc "Fetch kline data"
  task :scratch_daily, [:symbol] => :environment do |t, args|
      
    def generate_url(symbol, interval, start_time, end_time)
      start_time = start_time.to_i * 1e3.to_i 
      end_time = end_time.to_i * 1e3.to_i
      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    def fetch_with_proxy(queue, raw_records, initial_date_time)
      workers = []
      worker_count = 5
      worker_count.times do |i|
        workers << Thread.new do
          until queue.empty?
            item = queue.pop
        
            date_time = initial_date_time

            loop do

              if item[1] == "1m" || item[1] == "3m" || item[1] == "5m" || item[1] == "15m"
                start_time = date_time - i.days
                end_time = start_time + 1.days
              else
                start_time = date_time.beginning_of_month - i.months
                end_time = start_time.end_of_month
              end

              url = generate_url(item[0], item[1], start_time, end_time)

              response = Net::HTTP.get(url)

              content = JSON.parse(response)

              if content.empty?
                break
              end
              
              puts "Worker #{i}: #{start_time} #{url}"

              raw_records << [item[0], start_time.to_date, end_time.to_date, item[1], content]

              if item[1] == "1m" || item[1] == "3m" || item[1] == "5m" || item[1] == "15m"
                date_time = date_time - worker_count.day
              else
                date_time = date_time - worker_count.months
              end

              sleep(1)
            end
          end
        end
      end
      workers.each(&:join)
    end

    queue = Queue.new
    raw_records = Queue.new
    symbols = ["BCHUSDT", "XRPUSDT", "EOSUSDT", "LTCUSDT", "TRXUSDT"]
    p symbols
    all_intervals = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]
    symbols.product(all_intervals).each { |item| queue.push(item) }

    initial_date_time = DateTime.now.utc

    fetch_with_proxy(queue, raw_records, initial_date_time)

    all_entries = []

    all_entries << raw_records.pop until raw_records.empty?

    all_entries.each_slice(100) do |entries_slice|
      entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
        { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
      end
    
      BinanceFuturesKline.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])

      sql = <<-SQL
        INSERT INTO klines (symbol, interval, content, created_at, updated_at)
        SELECT DISTINCT
            symbol,
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
end