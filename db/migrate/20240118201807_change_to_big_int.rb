class ChangeToBigInt < ActiveRecord::Migration[7.1]
  def change
        add_column :binance_futures_klines, :start_time_bigint, :bigint
        add_column :binance_futures_klines, :end_time_bigint, :bigint
    
        sleep(1)
        # Remove old date columns
        remove_column :binance_futures_klines, :start_time
        remove_column :binance_futures_klines, :end_time
    
        sleep(1)
        # Rename new columns to original names
        rename_column :binance_futures_klines, :start_time_bigint, :start_time
        rename_column :binance_futures_klines, :end_time_bigint, :end_time
    
    
  end
end
