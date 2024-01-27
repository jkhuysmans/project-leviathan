namespace :klines_websocket do
  desc "TODO"
  task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

    $logger = Logger.new(File.join(Rails.root, 'log', 'output.log'))
    $klines_data = Queue.new

      def create_websocket_client(symbols, intervals)
        streams = symbols.product(intervals).map { |symbol, interval| "#{symbol}@kline_#{interval}" }
    
        $logger.info("Number of streams being listened to: #{streams.count}")
        
        threads = []

        streams.each_slice(1024) do |stream_slice|
          threads << Thread.new do

            batches = streams.each_slice(195).to_a

            base_url = "wss://stream.binance.com:9443/ws"
        
          WebSocket::Client::Simple.connect base_url do |ws|

            all_records = []

            ws.on :message do |msg|

              # $logger.info(msg.data)

              data = JSON.parse(msg.data)

              raw_records = JSON.parse(msg.data)
              records = raw_records['k']
              transformed_records = [records['t'], records['o'], records['h'], records['l'], records['c'], records['v'], records['T'], records['q'], records['n'], records['V'], records['Q'], "0"]
              all_records << raw_records

        
              def get_other_data(all_records, raw_records, timestamp)

                all_records.each do |record| 
                  if (((timestamp.to_i / 1000) / 2.round * 2) - 2) == (((record['E'].to_i / 1000)/ 2.round * 2))
                    symbol = record['k']['s']
                    interval = record['k']['i']
                    records = record['k']
                    transformed_record = [records['t'], records['o'], records['h'], records['l'], records['c'], records['v'], records['T'], records['q'], records['n'], records['V'], records['Q'], "0"]
                    $logger.info("open data = #{transformed_record}")
                  end
                end
                all_records.clear
              end
              
                if (data['k'] || {})['x']
                  kline_data = data['k']
                  
                  symbol = data['k']['s']
                  interval = data['k']['i']
                  timestamp = data['E']

                  transformed_data = [kline_data['t'], kline_data['o'], kline_data['h'], kline_data['l'], kline_data['c'], kline_data['v'], kline_data['T'], kline_data['q'], kline_data['n'], kline_data['V'], kline_data['Q'], "0"]

                  get_other_data(all_records, raw_records, timestamp)

                   $logger.info("closed data = #{transformed_data}")

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
                  $logger.info("Subscribe request for batch #{index + 1}: #{subscribe_request.to_json}")
                  ws.send(subscribe_request.to_json)
                end
             
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
        symbols = symbols[0..2]
        p symbols.count

        create_websocket_client(symbols, intervals)

        loop do
          sleep 60
        
        end


  end 
end