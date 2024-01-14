class AddIndexes < ActiveRecord::Migration[7.1]
  def change
     execute <<-SQL
	CREATE INDEX kline_idx ON klines USING GIN ((content -> 0));	
     SQL
     execute <<-SQL
	CREATE INDEX openinterests_idx ON open_interests USING GIN ((content -> 0));	
     SQL
  end
end
