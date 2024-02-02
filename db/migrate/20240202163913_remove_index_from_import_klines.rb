class RemoveIndexFromImportKlines < ActiveRecord::Migration[6.0] # Use the correct version
  def change
    remove_index :import_klines, name: 'import_klines_symbol_interval_int8_idx'
  end
end
