namespace :klines_websocket do
    desc "TODO"
    task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

      raw_records = Queue.new

        def create_websocket_client(symbols, intervals, raw_records)
          streams = symbols.product(intervals).map { |symbol, interval| "#{symbol}@kline_#{interval}" }
          puts streams.count
          
          threads = []

          streams.each_slice(1000) do |stream_slice|
            threads << Thread.new do


            stream_url = "wss://stream.binance.com:9443/stream?streams=#{stream_slice.join('/')}"
          
            WebSocket::Client::Simple.connect stream_url do |ws|

              ws.on :message do |msg|
            
                # puts msg.data
                  data = JSON.parse(msg.data)
                  if (data['data'] || {})['k']['x']
                    kline_data = data['data']['k']

                    stream_name = data['stream']
                    symbol, interval_info = stream_name.split('@')
                    interval = interval_info.split('_').last

                    transformed_data = [kline_data['t'], kline_data['o'], kline_data['h'], kline_data['l'], kline_data['c'], kline_data['v'], kline_data['T'], kline_data['q'], kline_data['n'], kline_data['V'], kline_data['Q'], "0"]

                    Kline.create(symbol: symbol.upcase(), interval: interval, content: transformed_data)
                    
                  end
              end
          
              ws.on :open do
                puts "Connected to"
              end
          
              ws.on :close do |e|
                puts "Closed connection to #{stream_url}"
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
          
      

          create_websocket_client(symbols, intervals, raw_records)

          loop do
            sleep 1
          end


    end 
end