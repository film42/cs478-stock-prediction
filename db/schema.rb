# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150408043833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "stock_predictions", force: :cascade do |t|
    t.string   "label"
    t.datetime "prediction_for"
    t.float    "price"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.float    "training_accuracy", default: 0.0, null: false
  end

  create_table "stock_prices", force: :cascade do |t|
    t.string   "label"
    t.float    "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "quote_for"
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
