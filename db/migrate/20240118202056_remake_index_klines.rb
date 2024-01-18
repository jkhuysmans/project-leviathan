class RemakeIndexKlines < ActiveRecord::Migration[7.1]
  def change
    remove_index :binance_futures_klines, name: 'index_unique_klines'
    sleep(1)
    add_index :binance_futures_klines, [:symbol, :start_time, :end_time, :interval], unique: true, name: 'index_unique_klines'
  end
end
