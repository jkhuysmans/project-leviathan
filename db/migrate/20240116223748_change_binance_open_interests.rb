class ChangeBinanceOpenInterests < ActiveRecord::Migration[7.1]
  def change
    add_column :binance_open_interests, :start_time, :date
    add_column :binance_open_interests, :end_time, :date
    remove_column :binance_open_interests, :day
  end
end
