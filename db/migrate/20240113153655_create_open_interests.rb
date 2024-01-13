class CreateOpenInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :open_interests do |t|

      t.timestamps
    end
  end
end
