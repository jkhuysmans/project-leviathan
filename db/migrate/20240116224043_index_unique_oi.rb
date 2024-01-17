class IndexUniqueOi < ActiveRecord::Migration[7.1]
  def change
    add_index :binance_open_interests, [:symbol, :start_time, :end_time, :interval], unique: true, name: 'index_unique_oi'
  end
end
