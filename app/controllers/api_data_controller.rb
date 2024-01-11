class ApiDataController < ApplicationController
  def parse_interval(interval)
    case interval
    when '1m'
      1
    when '3m'
      3
    when '5m'
      5
    when '15m'
      15
    when '30m'
      30
    when '1h'
      60
    when '2h'
      120
    when '4h'
      240
    when '6h'
      360
    when '8h'
      480
    when '12h'
      720
    when '24h', '1d'
      1440
    else
      nil
    end
  end

  def check_interval(kline, interval)
    timestamp_in_minutes = kline.content[0].to_i / 60000
    timestamp_in_minutes % interval == 0
  end

  def entries
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