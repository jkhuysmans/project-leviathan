namespace :klines_websocket do
  desc "TODO"
  task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

    $logger = Logger.new(File.join(Rails.root, 'log', 'output.log'))

    all_records = []

      def create_websocket_client(symbols, intervals, all_records)
        streams = symbols.product(intervals).map { |symbol, interval| "#{symbol}@kline_#{interval}" }
    
        $logger.info("Number of streams being listened to: #{streams.count}")
        
        threads = []

        streams.each_slice(1024) do |stream_slice|
          threads << Thread.new do

            batches = streams.each_slice(195).to_a

            base_url = "wss://stream.binance.com:9443/ws"
        
          WebSocket::Client::Simple.connect base_url do |ws|

            ws.on :message do |msg|

              data = JSON.parse(msg.data)

              if data['k']
              raw_record = JSON.parse(msg.data)
              records = raw_record['k']
              symbol = records['s']
              interval = records['i']
              transformed_record = [records['t'], records['o'], records['h'], records['l'], records['c'], records['v'], records['T'], records['q'], records['n'], records['V'], records['Q'], "0"]
              all_records << [symbol, interval, transformed_record]
              end
            end

            ws.on :open do
              $logger.info("Subscribed to #{base_url}")

              threads = []
              batches.each_with_index do |batch, index|
                  subscribe_request = {
                  "method": "SUBSCRIBE",
                  "params": batch,
                  "id": index + 1
                  }
                  # $logger.info("Subscribe request for batch #{index + 1}: #{subscribe_request.to_json}")
                  ws.send(subscribe_request.to_json)
                end

                list_subscriptions_request = {
                  method: "LIST_SUBSCRIPTIONS",
                  id: 3
                }
                # $logger.info("Requesting list of current subscriptions: #{list_subscriptions_request.to_json}")
                ws.send(list_subscriptions_request.to_json)    
            end
        
            ws.on :close do |e|
              puts "Closed connection to #{base_url}"
            end
        

          end
          end
        end

        threads.each(&:join)
      end

        def get_all_symbols
          url = URI('https://fapi.binance.com/fapi/v1/exchangeInfo')
          response = Net::HTTP.get(url)
          data = JSON.parse(response)
          all_symbols = data['symbols'].select { |data| data['status'] == "TRADING"}.map  { |data| data['symbol']}
          all_symbols
        end

        intervals = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]
        symbols = get_all_symbols.map { |symbol| symbol.downcase }
        symbols = symbols

        create_websocket_client(symbols, intervals, all_records)

        def insert_data(all_records)
          all_records.each_slice(4000) do |record_slice|
            csv_data = CSV.generate(force_quotes: true) do |csv|
              record_slice.each do |symbol, interval, content|
                content_json = content.to_json
                csv << [symbol, interval, content_json, Time.now, Time.now]
              end
            end
        
            # $logger.info("CSV: #{csv_data}")
            copy_sql = "COPY klines(symbol, interval, content, created_at, updated_at) FROM STDIN WITH CSV"
            Open3.popen3("psql -d leviathan_development") do |stdin, stdout, stderr, wait_thr|
              stdin.puts copy_sql
              stdin.puts csv_data
              stdin.close_write
        
              output = stdout.read
              error = stderr.read
              puts output unless output.empty?
              raise error unless error.empty?
            end
          end
        
          all_records.clear
        end
        

        loop do
          sleep 1
          if all_records.count > 100
            # $logger.info(all_records)
            insert_data(all_records)
          end
        end

  end 
end