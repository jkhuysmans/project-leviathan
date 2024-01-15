module Api
  module V1

class ApiDataController < ApplicationController
  def kline
    symbol = params[:symbol] || 'BTCUSDT'

    interval = params[:interval] || '1h'

    limit = params[:limit] || 20

    now = DateTime.now

    default_start_time = (now - 1.day).to_i * 1e3.to_i

    default_end_time =  now.to_i * 1e3.to_i

    start_time = params[:start_time] ? params[:start_time].to_i : default_start_time

    end_time = params[:end_time] ? params[:end_time].to_i : default_end_time

    entries = Kline.
      where(symbol: symbol, interval: interval).
      where('(content->>0)::bigint >= ?', start_time).
      where('(content->>0)::bigint <= ?', end_time).
      limit(limit)

    render json: entries
  end

  def openinterest
    def parse_interval(interval)
      all_possible_intervals = ["5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d"]
      all_possible_intervals.include?(interval)
    end
  
    def check_interval(oi, interval)
      oi.interval == interval
    end
  
    interval = params[:interval]
    if interval.blank? || !parse_interval(interval)
      render(json: { error: 'Invalid or missing interval' }, status: :bad_request) and return
    end

    symbol = params[:symbol]
    if symbol.blank?
      render(json: { error: 'Missing symbol' }, status: :bad_request) and return
    end

    default_start_time = ((DateTime.now.strftime('%s').to_i) * 1000) - 86400000

    start_time = params[:start_time] ? params[:start_time].to_i : default_start_time
    end_time = params[:end_time] ? params[:end_time].to_i : (start_time + 86400000)

    entries = symbol ? OpenInterests.where(symbol: symbol) : OpenInterests.all

    if start_time && end_time
      entries = entries.select do |oi|
        content_timestamp = oi.content["timestamp"].to_i
        content_timestamp.between?(start_time, end_time)
      end
    end

    entries = entries.select { |oi| check_interval(oi, interval) } if interval

    render json: entries
  end
end

end 
end