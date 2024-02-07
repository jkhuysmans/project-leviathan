namespace :klines_websocket do
  desc "TODO"
  task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

    $logger = Logger.new(File.join(Rails.root, 'log', 'output.log'))
    websocket_clients = []

    all_records = []


      def create_websocket_client(symbols, intervals, all_records, websocket_clients)
        streams = symbols.product(intervals).map { |symbol, interval| "#{symbol}@kline_#{interval}" }

        $logger.info("Number of streams being listened to: #{streams.count}")
        
        threads = []

        streams.each_slice(195) do |stream_slice|
          threads << Thread.new do

            base_url = "wss://stream.binance.com:9443/ws"

            last_message_time = Time.now

            reset_timer = -> { last_message_time = Time.now }
        
          WebSocket::Client::Simple.connect base_url do |ws|
            $active = true
            websocket_clients << ws
            
            ws.on :message do |msg|

              reset_timer.call
              # $logger.info(msg.data)

              if msg.type == :ping
                ws.send(msg.data, type: :pong)
              else

              data = JSON.parse(msg.data)

              if data.key?('result') && data.key?('id')
                $logger.info("Subscription message received: #{msg.data}")
              end

              if data['k']
              raw_record = JSON.parse(msg.data)
              records = raw_record['k']
              symbol = records['s']
              interval = records['i']
              transformed_record = [records['t'], records['o'], records['h'], records['l'], records['c'], records['v'], records['T'], records['q'], records['n'], records['V'], records['Q'], "0"]
              all_records << [symbol, interval, transformed_record]
              end
            end
            end

            ws.on :open do
              $logger.info("Subscribed to #{base_url}")

              threads = []
              batches = stream_slice.each_slice(200).to_a

              batches.each_with_index do |batch, index|
                  subscribe_request = {
                  "method": "SUBSCRIBE",
                  "params": batch,
                  "id": 1
                  }
                  ws.send(subscribe_request.to_json)
                end  
            end
        
            ws.on :close do |e|
              $logger.info("Closed connection")
            end

            Thread.new do
              loop do
                break unless $active
                if Time.now - last_message_time > 30
                  $logger.info("No new message in the last 30 seconds.")
                  
                  reconnection(symbols, intervals, all_records, websocket_clients)
                  reset_timer.call
                end
                sleep 1
              end
            end

          end
        end
        end
        threads.each(&:join)

        reconnection_thread = Thread.new do
             
          sleep_time = (24 * 60 * 60) - 580 
          sleep(sleep_time)
      
          reconnection(symbols, intervals, all_records, websocket_clients)
  
        end
      end

      def reconnection(symbols, intervals, all_records, websocket_clients)
        $active = false

        sleep(1)

        websocket_clients.each do |ws_client|
          ws_client.close if ws_client.open?
        end

        websocket_clients.clear
    
        puts "Reconnecting"
        $logger.info("Reconnecting...")
        create_websocket_client(symbols, intervals, all_records, websocket_clients)
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

        create_websocket_client(symbols, intervals, all_records, websocket_clients)

        def insert_data(all_records)
          $logger.info("Start inserting data...")
          start = Time.now
          file_path = Rails.root.join('data.csv').to_s
        
          ActiveRecord::Base.connection.execute("TRUNCATE import_klines;") 
         
          csv_data = CSV.generate(force_quotes: true) do |csv|
            csv << ['symbol', 'interval', 'content', 'created_at', 'updated_at']
            all_records.each do |symbol, interval, content|
              content_json = content.to_json
              csv << [symbol, interval, content_json, Time.now.utc, Time.now.utc]
            end
          end
        
          copy_command = "psql -d leviathan_production -c \"\\COPY import_klines(symbol, interval, content, created_at, updated_at) FROM STDIN WITH CSV HEADER\""
          
          ActiveRecord::Base.connection.raw_connection.tap do |conn|
            conn.copy_data "COPY import_klines(symbol, interval, content, created_at, updated_at) FROM STDIN WITH CSV HEADER" do
              conn.put_copy_data(csv_data)
            end
          end
        
          insert_command = "INSERT INTO klines SELECT * FROM import_klines WHERE NOT EXISTS (SELECT 1 FROM klines WHERE klines.symbol = import_klines.symbol AND klines.interval = import_klines.interval AND (klines.content->>0)::bigint = (import_klines.content->>0)::bigint) ON CONFLICT DO NOTHING"
          system("psql -d leviathan_production -c \"#{insert_command}\"")

          all_records.clear
          $logger.info("Took #{Time.now - start}")
        end

        loop do
          sleep 1
          p all_records.count
          if all_records.count > 10000
            puts "inserting data at #{Time.now}"
            insert_data(all_records)
          end
        end

  end 
end