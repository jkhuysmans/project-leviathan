# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_16_224043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "binance_futures_klines", force: :cascade do |t|
    t.text "symbol"
    t.date "start_time"
    t.date "end_time"
    t.text "interval"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol", "start_time", "end_time", "interval"], name: "index_unique_klines", unique: true
  end

  create_table "binance_open_interests", force: :cascade do |t|
    t.text "symbol"
    t.text "interval"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_time"
    t.date "end_time"
    t.index ["symbol", "start_time", "end_time", "interval"], name: "index_unique_oi", unique: true
  end

  create_table "klines", force: :cascade do |t|
    t.text "symbol"
    t.date "day"
    t.text "interval"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "symbol, \"interval\", (((content ->> 0))::bigint)", name: "kline_ydx", unique: true
  end

  create_table "open_interests", force: :cascade do |t|
    t.text "symbol"
    t.date "day"
    t.text "interval"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
