class AddUniqueConstraintToKlines < ActiveRecord::Migration[7.1]
  def change
    execute "create unique index kline_ydx on klines (symbol, interval, ((content->>0)::bigint));"
  end
end
