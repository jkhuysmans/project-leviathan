namespace :klines_websocket do
    desc "TODO"
    task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

      raw_records = Queue.new

        def create_websocket_client(symbols, intervals, raw_records)
          streams = symbols.product(intervals).map { |symbol, interval| "#{symbol}@kline_#{interval}" }
          stream_url = "wss://stream.binance.com:9443/stream?streams=#{streams.join('/')}"

          puts stream_url
          
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

                    p transformed_data
                    Kline.create(symbol: symbol.upcase(), interval: interval, content: transformed_data)
                    
                  end
              end
          
              ws.on :open do
                puts "Connected to #{stream_url}"
              end
          
              ws.on :close do |e|
                puts "Closed connection to #{stream_url}"
              end
          
              
            end
          end

          intervals = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]
          symbols = ["btcusdt"]
      
          create_websocket_client(symbols, intervals, raw_records)

          loop do
            sleep 1
          end


    end 
end