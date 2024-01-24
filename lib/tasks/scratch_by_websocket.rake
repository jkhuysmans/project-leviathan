namespace :klines_websocket do
    desc "TODO"
    task :scratch_by_minute, [:symbol, :month] => :environment do |t, args|

      raw_records = Queue.new

        def create_websocket_client(symbol, interval, raw_records)
          stream_url = "wss://stream.binance.com:9443/ws/#{symbol}@kline_#{interval}"
            WebSocket::Client::Simple.connect stream_url do |ws|

              ws.on :message do |msg|
            
                  data = JSON.parse(msg.data)
                  if (data['k'] || {})['x']
                    kline_data = data['k']

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
          all = symbols.product(intervals)

          threads = []
          all.each do |symbol, interval|
            threads << Thread.new do
              create_websocket_client(symbol, interval, raw_records)
            end
          end
      
          threads.each(&:join)

          loop do
            sleep 1
          end


    end 
end