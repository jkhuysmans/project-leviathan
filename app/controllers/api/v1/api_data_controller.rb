module Api
  module V1

class ApiDataController < ApplicationController
  def kline
    def parse_interval(interval)
      all_possible_intervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M']
      all_possible_intervals.include?(interval) ? interval : nil
    end

    def check_interval(kline, interval)
      kline_interval = kline.interval
      kline_interval == interval
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

    entries = symbol ? Kline.where(symbol: symbol) : Kline.all

    if start_time && end_time
      entries = entries.select do |kline|
        content_first_element = kline.content[0].to_i
        content_first_element.between?(start_time, end_time)
      end
    end

    entries = entries.select { |kline| check_interval(kline, interval) } if interval

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