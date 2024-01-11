class ApiDataController < ApplicationController
  def entries
    def parse_interval(interval)
      all_possible_intervals = ['1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M']
      all_possible_intervals.include?(interval) ? interval : nil
    end

    def check_interval(kline, interval)
      kline_interval = kline.interval
      kline_interval == interval
    end

    symbol = params[:symbol]
    interval = parse_interval(params[:interval])
    start_time = params[:start_time] ? params[:start_time].to_i : nil
    end_time = params[:end_time] ? params[:end_time].to_i : nil

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
end