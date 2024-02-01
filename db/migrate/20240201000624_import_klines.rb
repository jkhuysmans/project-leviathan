class ImportKlines < ActiveRecord::Migration[7.1]
  def change
    execute 'CREATE TABLE import_klines (LIKE klines INCLUDING ALL)'
  end
end
