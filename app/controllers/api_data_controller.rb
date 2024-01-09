class ApiDataController < ApplicationController
  def entries
    symbol = params[:symbol]
    start_time = params[:start_time] ? params[:start_time].to_i : nil
    end_time = params[:end_time] ? params[:end_time].to_i : nil

    entries = Kline.where(symbol: symbol) if symbol
    entries = Kline.all unless symbol

    if start_time && end_time
      entries = entries.select do |kline|
        content_first_element = kline.content[0].to_i
        content_first_element.between?(start_time, end_time)
      end
    end

    render json: entries
  end
end