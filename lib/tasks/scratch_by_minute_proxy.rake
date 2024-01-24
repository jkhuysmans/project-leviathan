namespace :klines_proxy do
  desc "TODO"
  task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

    start = Time.now

    def fetch_with_proxy(proxy_config, queue, raw_records, date_time)
      worker_count = 6
      workers = []
      start_thread = Time.now

      worker_count.times do
        workers << Thread.new do
        until queue.empty?
          item = queue.pop

          url_start = Time.now
  
          if item[1] == "1m" || item[1] == "3m" || item[1] == "5m" || item[1] == "15m"
              start_time = date_time.beginning_of_day
              end_time = date_time.end_of_day
          else
              start_time = date_time.beginning_of_month
              end_time = date_time.end_of_month
            end

          start_time = start_time.to_i * 1e3.to_i
          end_time = end_time.to_i * 1e3.to_i
          
          url = generate_url(item[0], item[1], start_time, end_time)
          
          start_parse = Time.now
  
          if proxy_config[:host] == nil
            start_local = Time.now
            response_body = Net::HTTP.get(url)
          else
            start_proxy = Time.now
            proxy = Net::HTTP::Proxy(proxy_config[:host], proxy_config[:port], proxy_config[:password])

            http = proxy.new(url.host, url.port)
            http.use_ssl = (url.scheme == 'https')
  
            request = Net::HTTP::Get.new(url)
            response = http.request(request)
  
            response_body = response.body
          
          end

          content = JSON.parse(response_body)
  
          raw_records << [item[0], start_time, end_time, item[1], content]

          sleep(1)

          # puts "fetched in #{Time.now - start_parse} from #{}"
        end
        
        end
      end
      
      workers.each(&:join)
    end

  def get_all_symbols
    url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    all_symbols = data['symbols'].select { |data| data['status'] == "TRADING"}.map  { |data| data['symbol']}
    all_symbols
  end

  def generate_url(symbol, interval, start_time, end_time)
    URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
  end

  all_symbols = get_all_symbols
  all_symbols = all_symbols[0..11]
  puts "Time fetching symbols: #{Time.now - start}"
  all_intervals = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]

  queue = Queue.new
  all_symbols.product(all_intervals).each { |item| queue.push(item) }

  raw_records = Queue.new

  date_time = DateTime.now.utc

  proxies = [
    {host: '54.74.136.212', port: '3128', password: 'CNALavjy6nuWl6bdbaB8Ug'},
    {host: '54.74.136.212', port: '3128', password: 'CNALavjy6nuWl6bdbaB8Ug'}
  ]
  start_download = Time.now 

  futures = []
  
proxies.each do |proxy_config|
  
  future = Concurrent::Future.execute do
    puts Time.now
    fetch_with_proxy(proxy_config, queue, raw_records, date_time)
    puts Time.now
  end
  futures << future
end

futures.each(&:wait)


  puts "time spent downloading: #{Time.now - start_download}"
  insert_bfk = Time.now

  all_entries = []

  all_entries << raw_records.pop until raw_records.empty?

  all_entries.each do |entries_slice|
    entries = entries_slice.map do |symbol, start_time, end_time, interval, content|
      { symbol: symbol, start_time: start_time, end_time: end_time, interval: interval, content: content }
    end
    BinanceFuturesKline.upsert_all(entries, unique_by: [:symbol, :start_time, :end_time, :interval])
  end

  puts "insert raw data: #{Time.now - insert_bfk}"
  sort_data = Time.now

  sql = <<-SQL
      insert into klines (symbol, interval, content, created_at, updated_at)
      select distinct
          symbol,
          interval,
          value as content,
          now() as created_at,
          now() as updated_at
      from binance_futures_klines, jsonb_array_elements(content) as value
      where jsonb_typeof(content) = 'array'
      and start_time > #{date_time.last_month.beginning_of_month.to_i * 1e3.to_i}
      AND EXISTS (
    SELECT 1 FROM klines WHERE (content->>0)::bigint > #{date_time.beginning_of_month.to_i * 1e3.to_i}
)
      on conflict do nothing;
  SQL
  ActiveRecord::Base.connection.execute(sql)

  puts "Data transformed in #{Time.now - sort_data}"

  puts "done in: #{Time.now - start}"
end

end