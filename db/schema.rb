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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130303024917) do

  create_table "amount_of_currencies", :force => true do |t|
    t.integer  "member_id"
    t.integer  "currency_id"
    t.integer  "amount"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "currencies", :force => true do |t|
    t.integer  "currency_id"
    t.string   "name"
    t.integer  "publisher"
    t.string   "unit"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "log_for_currencies", :force => true do |t|
    t.integer  "currency_id"
    t.integer  "amount"
    t.text     "log"
    t.integer  "from_member_id"
    t.integer  "to_member_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "operation_date"
  end

  create_table "members", :force => true do |t|
    t.integer  "member_id"
    t.string   "name"
    t.string   "profile"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "money_tickets", :force => true do |t|
    t.string   "ticket_id"
    t.integer  "currency_id"
    t.integer  "amount"
    t.string   "status"
    t.datetime "used_date"
    t.datetime "expire_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
