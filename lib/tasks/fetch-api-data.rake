namespace :api_data_fetcher do
    desc "Retrieve data from Binance"
    task fetch_data: :environment do

      def fetch(symbol, date, interval)
        unix_starttime = (Time.parse(date + ' 00:00:00 GMT').to_i)
        unix_endtime = (unix_starttime + 86399) * 1000 
        unix_starttime *= 1000
    
        puts "https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{unix_starttime}&endtime=#{unix_endtime}&limit=1500"
    end  
      
    puts fetch("BTCUSDT", "2024/01/06", "1h")
    puts fetch("ETHUSDT", "2024/01/07", "1m")
      
    end
  
  end
  