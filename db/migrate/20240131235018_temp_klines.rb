class TempKlines < ActiveRecord::Migration[7.1]
  def up
    execute 'CREATE TABLE import_klines (LIKE klines INCLUDING ALL)'
  end

  def down
    execute 'DROP TABLE IF EXISTS import_klines'
  end
end
