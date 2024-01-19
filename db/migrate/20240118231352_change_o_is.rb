class ChangeOIs < ActiveRecord::Migration[7.1]
  def change
    add_column :binance_open_interests, :start_time_bigint, :bigint
    add_column :binance_open_interests, :end_time_bigint, :bigint
    
        sleep(1)
    remove_column :binance_open_interests, :start_time
    remove_column :binance_open_interests, :end_time
    
        sleep(1)
    rename_column :binance_open_interests, :start_time_bigint, :start_time
    rename_column :binance_open_interests, :end_time_bigint, :end_time
  end
end
