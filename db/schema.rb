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

ActiveRecord::Schema[7.1].define(version: 2025_05_25_071617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "título"
    t.string "nível"
    t.text "texto"
    t.string "video_url"
    t.string "imagem_url"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "texte"
    t.text "elements_order"
    t.integer "video_order", default: 1
    t.integer "imagem_order", default: 2
    t.integer "texte_order", default: 3
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "alternatives", force: :cascade do |t|
    t.text "conteúdo"
    t.boolean "correta", default: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_alternatives_on_question_id"
  end

  create_table "completed_activities", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "activity_id", null: false
    t.integer "score"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id"
    t.integer "total_questions"
    t.decimal "percentage"
    t.index ["activity_id"], name: "index_completed_activities_on_activity_id"
    t.index ["student_id", "activity_id"], name: "index_completed_activities_on_student_id_and_activity_id", unique: true, where: "(student_id IS NOT NULL)"
    t.index ["student_id"], name: "index_completed_activities_on_student_id"
    t.index ["user_id", "activity_id"], name: "index_completed_activities_on_user_id_and_activity_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_completed_activities_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "conteúdo"
    t.string "tipo"
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order"
    t.index ["activity_id"], name: "index_questions_on_activity_id"
  end

  create_table "statements", force: :cascade do |t|
    t.text "conteúdo"
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
    t.integer "display_order"
    t.index ["activity_id"], name: "index_statements_on_activity_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_streak", default: 0
    t.integer "best_streak", default: 0
    t.date "last_activity_date"
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true
  end

  create_table "suggestions", force: :cascade do |t|
    t.text "conteúdo"
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order"
    t.index ["activity_id"], name: "index_suggestions_on_activity_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "users"
  add_foreign_key "alternatives", "questions"
  add_foreign_key "completed_activities", "activities"
  add_foreign_key "completed_activities", "students"
  add_foreign_key "completed_activities", "users"
  add_foreign_key "questions", "activities"
  add_foreign_key "statements", "activities"
  add_foreign_key "suggestions", "activities"
end
