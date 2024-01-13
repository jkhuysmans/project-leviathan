class CreateBinanceOpenInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :binance_open_interests do |t|
      t.text :symbol
      t.date :day
      t.text :interval
      t.jsonb :content

      t.timestamps
    end
  end
end
