class AddIndexes < ActiveRecord::Migration[7.1]
  def change
     execute <<-SQL
	CREATE INDEX kline_idx ON klines USING GIN ((content -> 0));	
     SQL
  end
end
