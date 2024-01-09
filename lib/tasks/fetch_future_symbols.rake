namespace :fetch_future_symbols do
  desc "Fetches all Binance future symbols and returns them into an array"
  task binance_symbols: :environment do

    all_binance_klines = BinanceFuturesKline.where(id: [1330, 1331, 1332, 1333, 1334, 1335, 1336])

    all_binance_klines.each do |klines_from_binance|
      content_data = klines_from_binance.content

      content_data.each do |interval_data|
        Kline.create(
          symbol: klines_from_binance.symbol,
          day: klines_from_binance.day,
          interval: klines_from_binance.interval,
          content: interval_data
        )
      end
    end

  end

end
