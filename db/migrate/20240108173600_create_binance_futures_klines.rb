class CreateBinanceFuturesKlines < ActiveRecord::Migration[7.1]
  def change
    create_table :binance_futures_klines do |t|
      t.text :symbol
      t.date :start_time
      t.date :end_time
      t.text :interval
      t.jsonb :content

      t.timestamps
    end
  end
end
