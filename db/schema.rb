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

ActiveRecord::Schema[7.1].define(version: 2025_05_28_144503) do
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

  create_table "activity_ratings", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "activity_id", null: false
    t.integer "stars", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_ratings_on_activity_id"
    t.index ["student_id", "activity_id"], name: "index_activity_ratings_on_student_id_and_activity_id", unique: true
    t.index ["student_id"], name: "index_activity_ratings_on_student_id"
    t.check_constraint "stars >= 1 AND stars <= 5", name: "stars_range_check"
  end

  create_table "alternatives", force: :cascade do |t|
    t.text "conteúdo"
    t.boolean "correta", default: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_alternatives_on_question_id"
  end

  create_table "association_pairs", force: :cascade do |t|
    t.bigint "column_association_id", null: false
    t.string "item_a", null: false
    t.string "item_b", null: false
    t.integer "pair_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["column_association_id", "pair_order"], name: "idx_on_column_association_id_pair_order_50a71b93fe", unique: true
    t.index ["column_association_id"], name: "index_association_pairs_on_column_association_id"
  end

  create_table "blanks", force: :cascade do |t|
    t.integer "position"
    t.string "correct_answer"
    t.bigint "fill_blank_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fill_blank_id"], name: "index_blanks_on_fill_blank_id"
  end

  create_table "column_associations", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.string "title", null: false
    t.text "instruction"
    t.string "column_a_title", default: "Première colonne"
    t.string "column_b_title", default: "Seconde colonne"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_column_associations_on_activity_id"
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

  create_table "fill_blanks", force: :cascade do |t|
    t.text "conteúdo"
    t.bigint "activity_id", null: false
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_fill_blanks_on_activity_id"
  end

  create_table "paragraph_orderings", force: :cascade do |t|
    t.string "titre"
    t.text "instruction"
    t.bigint "activity_id", null: false
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_paragraph_orderings_on_activity_id"
  end

  create_table "paragraph_sentences", force: :cascade do |t|
    t.text "sentence"
    t.integer "correct_position"
    t.integer "display_position"
    t.bigint "paragraph_ordering_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paragraph_ordering_id"], name: "index_paragraph_sentences_on_paragraph_ordering_id"
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

  create_table "sentence_orderings", force: :cascade do |t|
    t.text "conteúdo"
    t.bigint "activity_id", null: false
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_sentence_orderings_on_activity_id"
  end

  create_table "sentence_words", force: :cascade do |t|
    t.string "word"
    t.integer "correct_position"
    t.integer "display_position"
    t.bigint "sentence_ordering_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sentence_ordering_id"], name: "index_sentence_words_on_sentence_ordering_id"
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
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["invitation_token"], name: "index_students_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_students_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_students_on_invited_by"
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
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "users"
  add_foreign_key "activity_ratings", "activities"
  add_foreign_key "activity_ratings", "students"
  add_foreign_key "alternatives", "questions"
  add_foreign_key "association_pairs", "column_associations"
  add_foreign_key "blanks", "fill_blanks"
  add_foreign_key "column_associations", "activities"
  add_foreign_key "completed_activities", "activities"
  add_foreign_key "completed_activities", "students"
  add_foreign_key "completed_activities", "users"
  add_foreign_key "fill_blanks", "activities"
  add_foreign_key "paragraph_orderings", "activities"
  add_foreign_key "paragraph_sentences", "paragraph_orderings"
  add_foreign_key "questions", "activities"
  add_foreign_key "sentence_orderings", "activities"
  add_foreign_key "sentence_words", "sentence_orderings"
  add_foreign_key "statements", "activities"
  add_foreign_key "suggestions", "activities"
end
