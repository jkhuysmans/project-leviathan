module Api
  module V1

class ApiDataController < ApplicationController
  def kline
    symbol = params[:symbol] || 'BTCUSDT'

    interval = params[:interval] || '1h'

    limit = params[:limit] || 1500

    now = DateTime.now

    default_start_time = (now - 1.day).to_i * 1e3.to_i

    default_end_time =  now.to_i * 1e3.to_i

    start_time = params[:start_time] ? params[:start_time].to_i : default_start_time

    end_time = params[:end_time] ? params[:end_time].to_i : default_end_time

    entries = Kline.
      where(symbol: symbol, interval: interval).
      where('(content->>0)::bigint >= ?', start_time).
      where('(content->>0)::bigint <= ?', end_time).
      order(Arel.sql('(content->>0)::bigint DESC')).
      group(:content).
      limit(limit).
      pluck(:content)

      entries.reverse!

      result = {
      "symbol": symbol,
      "start_time": start_time,
      "end_time": end_time,
      "interval": interval,
      "klines": entries
    }

    render json: result
  end

  def openinterest
    symbol = params[:symbol] || 'BTCUSDT'

    interval = params[:interval] || '1h'

    limit = params[:limit] || 1500

    now = DateTime.now

    default_start_time = (now - 1.day).to_i * 1e3.to_i

    default_end_time =  now.to_i * 1e3.to_i

    start_time = params[:start_time] ? params[:start_time].to_i : default_start_time

    end_time = params[:end_time] ? params[:end_time].to_i : default_end_time

    entries = OpenInterests.
      where(symbol: symbol, interval: interval).
      where("((content ->> 'timestamp')::bigint >= ?)", start_time).
      where("((content ->> 'timestamp')::bigint <= ?)", end_time).
      order(Arel.sql("((content ->> 'timestamp')::bigint) DESC")).
      group(:content).
      limit(limit).
      pluck(:content)

      entries.reverse!

      result = {
      "symbol": symbol,
      "start_time": start_time,
      "end_time": end_time,
      "interval": interval,
      "open interests": entries
    }

    render json: result
  end
end

end 
end