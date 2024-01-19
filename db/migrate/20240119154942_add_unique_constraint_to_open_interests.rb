class AddUniqueConstraintToOpenInterests < ActiveRecord::Migration[7.1]
  def change
    execute "create unique index oi_ydx on open_interests (symbol, interval, ((content ->> 'timestamp')::bigint));"
  end
end
