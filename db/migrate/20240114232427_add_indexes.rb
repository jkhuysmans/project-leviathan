class AddIndexes < ActiveRecord::Migration[7.1]
  def change
    execute <<-SQL
    CREATE INDEX kline_idx on kline(symbol, content->>[0]);
      SQL
  end
end