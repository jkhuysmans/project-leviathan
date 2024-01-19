class FixOiIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :binance_open_interests, name: 'index_unique_oi'
    sleep(1)
    add_index :binance_open_interests, [:symbol, :start_time, :end_time, :interval], unique: true, name: 'index_unique_oi'
  end
end
