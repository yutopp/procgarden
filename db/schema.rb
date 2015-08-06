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

ActiveRecord::Schema.define(version: 20150802014650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "visibility"
    t.integer  "viewed_count"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "exec_tasks", force: :cascade do |t|
    t.integer  "index",                                null: false
    t.text     "commands"
    t.text     "options"
    t.text     "stdin"
    t.boolean  "is_stdout_merged",     default: false, null: false
    t.text     "sent_envs"
    t.text     "sent_commands"
    t.boolean  "exited"
    t.integer  "exit_status"
    t.boolean  "signaled"
    t.integer  "signal"
    t.float    "used_cpu_time_sec"
    t.integer  "used_memory_bytes"
    t.integer  "system_error_status"
    t.string   "system_error_message"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "compile_ticket_id"
    t.integer  "link_ticket_id"
    t.integer  "exec_ticket_id"
  end

  add_index "exec_tasks", ["compile_ticket_id"], name: "index_exec_tasks_on_compile_ticket_id", using: :btree
  add_index "exec_tasks", ["exec_ticket_id"], name: "index_exec_tasks_on_exec_ticket_id", using: :btree
  add_index "exec_tasks", ["link_ticket_id"], name: "index_exec_tasks_on_link_ticket_id", using: :btree

  create_table "result_streams", force: :cascade do |t|
    t.integer  "exec_task_id"
    t.integer  "fd",           null: false
    t.binary   "buffer",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "source_codes", force: :cascade do |t|
    t.integer  "entry_id"
    t.string   "name",       default: "*default*", null: false
    t.text     "source",     default: "",          null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "entry_id"
    t.integer  "index",                        null: false
    t.boolean  "do_execute",                   null: false
    t.string   "proc_name",                    null: false
    t.string   "proc_version",                 null: false
    t.string   "proc_label",                   null: false
    t.integer  "phase",                        null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_finished",  default: false, null: false
  end

end
