namespace :api_data_fetcher do
    desc "Retrieve data from Binance"
    task fetch_data: :environment do
      require 'binance'
      
      client = Binance::Spot.new(key: 'b8w5P4AajVzVFZSDkxcb0prLNzs8j6aEBVlyJg5IHtdEy8cjPRuCwN9QSALBfItc', secret: 'pmdsAR11aL8TFuPcV4fHNxLLJDcA8m8Ku60zJNGlGoEcDAe1wabVGQW6YAhhLRsO')

      btcusdt_kline = client.klines(symbol: 'BTCUSDT', interval: '1h', limit: '10')
      p btcusdt_kline
    end
  
  end
  