class RemakeIndexKlines < ActiveRecord::Migration[7.1]
  def change
    add_index :binance_futures_klines, [:symbol, :start_time, :end_time, :interval], unique: true, name: 'index_unique_klines'
  end
end
