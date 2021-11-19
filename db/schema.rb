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

ActiveRecord::Schema.define(version: 2021_07_13_132949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_settings", force: :cascade do |t|
    t.bigint "account_id"
    t.string "no_of_employees"
    t.integer "industry_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "billing_emails"
    t.index ["account_id"], name: "index_account_settings_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "your_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "company", default: true
    t.string "company_name"
    t.string "company_email"
    t.string "sender_email"
    t.boolean "admin", default: false
    t.bigint "account_id"
    t.integer "role"
    t.integer "active", default: 0
    t.string "invitation_code"
    t.boolean "allowed_to_log_in", default: true
    t.string "account_type", default: "client"
    t.boolean "archived", default: false
    t.boolean "require_new_password", default: false
    t.datetime "last_seen_at"
    t.boolean "new_account", default: true
    t.string "provider"
    t.string "uid"
    t.integer "login_options", default: 0
    t.string "first_name"
    t.string "last_name"
    t.integer "user_limit", default: 1
    t.datetime "deleted_at"
    t.datetime "recreated_at"
    t.boolean "trial", default: false
    t.text "trial_password"
    t.integer "survey_limit", default: 1
    t.integer "block_limit", default: 1
    t.integer "question_limit", default: 1
    t.datetime "invite_sent_at"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["provider"], name: "index_accounts_on_provider"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_accounts_on_uid"
    t.index ["unlock_token"], name: "index_accounts_on_unlock_token", unique: true
  end

  create_table "accounts_email_notification_types", id: false, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "email_notification_type_id", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
    t.boolean "cloned", default: false
    t.integer "cloned_from"
    t.integer "account_id"
    t.string "display_type"
    t.string "block_button_color", default: "#26a69a"
    t.bigint "survey_id"
    t.bigint "master_id"
    t.boolean "saved_block", default: false
    t.string "block_relation_type"
    t.boolean "is_branching", default: false
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "categories_industries", force: :cascade do |t|
    t.integer "industry_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_surveys", force: :cascade do |t|
    t.integer "survey_id"
    t.integer "category_id"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_template_themes", force: :cascade do |t|
    t.bigint "template_theme_id", null: false
    t.bigint "category_id", null: false
    t.integer "position", default: 0
  end

  create_table "custom_personas", force: :cascade do |t|
    t.string "title"
    t.string "persona_name"
    t.bigint "survey_id"
    t.bigint "group_id"
    t.integer "created_by_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data_json"
    t.string "gender"
    t.string "gender_image_slug"
    t.string "public_token"
    t.index ["account_id"], name: "index_custom_personas_on_account_id"
    t.index ["data_json"], name: "index_custom_personas_on_data_json", using: :gin
    t.index ["group_id"], name: "index_custom_personas_on_group_id"
    t.index ["survey_id"], name: "index_custom_personas_on_survey_id"
  end

  create_table "custom_personas_submissions", id: false, force: :cascade do |t|
    t.bigint "custom_persona_id", null: false
    t.bigint "submission_id", null: false
  end

  create_table "email_notification_types", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "title"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.boolean "archived", default: false
    t.index ["account_id"], name: "index_groups_on_account_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "slug_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "industries_surveys", id: false, force: :cascade do |t|
    t.bigint "industry_id"
    t.bigint "survey_id"
    t.index ["industry_id"], name: "index_industries_surveys_on_industry_id"
    t.index ["survey_id"], name: "index_industries_surveys_on_survey_id"
  end

  create_table "industries_template_themes", force: :cascade do |t|
    t.integer "industry_id"
    t.integer "template_theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "label_templates", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "question_type"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "other_specify"
    t.integer "geographic_type"
    t.integer "star_rating_range", default: 5
    t.integer "star_rating_shape", default: 0
    t.integer "star_rating_labels", default: 0
    t.integer "range_slider_left", default: 0
    t.integer "range_slider_right", default: 10
    t.integer "range_slider_step", default: 1
    t.integer "range_slider_position", default: 0
    t.integer "other_label_max_length", default: 0
    t.integer "other_label_min_length", default: 10
    t.string "default_type", default: "user-custom"
    t.string "slug_id", default: "user-slug-id"
    t.integer "template_type", default: 0
    t.index ["account_id"], name: "index_label_templates_on_account_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "title"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.boolean "archived", default: false
    t.index ["account_id"], name: "index_lists_on_account_id"
  end

  create_table "lists_recipients", force: :cascade do |t|
    t.integer "list_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists_surveys", id: false, force: :cascade do |t|
    t.bigint "list_id"
    t.bigint "survey_id"
    t.index ["list_id"], name: "index_lists_surveys_on_list_id"
    t.index ["survey_id"], name: "index_lists_surveys_on_survey_id"
  end

  create_table "question_labels", force: :cascade do |t|
    t.string "label"
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "score"
    t.integer "max_length"
    t.integer "min_length"
    t.bigint "label_template_id"
    t.integer "position", default: 0
    t.boolean "show_label", default: true
    t.string "tag"
    t.boolean "show_tag", default: true
    t.boolean "correct_answer", default: true
    t.integer "branch_to", default: 0
    t.index ["label_template_id"], name: "index_question_labels_on_label_template_id"
    t.index ["question_id"], name: "index_question_labels_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.integer "question_type"
    t.boolean "required", default: true
    t.integer "chart_type"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data_json"
    t.integer "other_label_max_length"
    t.integer "other_label_min_length"
    t.integer "position", default: 0
    t.bigint "account_id"
    t.integer "label_template_id", default: 0
    t.integer "other_specify"
    t.integer "geographic_type"
    t.integer "star_rating_range", default: 5
    t.integer "star_rating_shape", default: 0
    t.integer "star_rating_labels", default: 0
    t.integer "range_slider_left", default: 0
    t.integer "range_slider_right", default: 10
    t.integer "range_slider_step", default: 1
    t.integer "range_slider_position", default: 0
    t.boolean "is_branching", default: false
    t.boolean "sort_results", default: false
    t.index ["account_id"], name: "index_questions_on_account_id"
    t.index ["category_id"], name: "index_questions_on_category_id"
    t.index ["data_json"], name: "index_questions_on_data_json", using: :gin
  end

  create_table "recipients", force: :cascade do |t|
    t.bigint "account_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "gender"
    t.string "image_slug", default: "men-1"
    t.integer "created_by_id"
    t.string "encrypted_mail"
    t.index ["account_id"], name: "index_recipients_on_account_id"
  end

  create_table "recipients_surveys", force: :cascade do |t|
    t.integer "survey_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "list_id"
    t.string "allow_survey"
    t.index ["allow_survey"], name: "index_recipients_surveys_on_allow_survey"
    t.index ["list_id"], name: "index_recipients_surveys_on_list_id"
    t.index ["recipient_id"], name: "index_recipients_surveys_on_recipient_id"
    t.index ["survey_id"], name: "index_recipients_surveys_on_survey_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "submission_answers", force: :cascade do |t|
    t.text "answer"
    t.text "label"
    t.text "answer_other"
    t.text "answer_data_type"
    t.text "time_spent"
    t.text "block_type"
    t.text "question_title"
    t.text "question_description"
    t.integer "question_type"
    t.integer "question_other_specify"
    t.text "category_title"
    t.text "category_description"
    t.text "category_display_type"
    t.bigint "survey_id"
    t.bigint "submission_id"
    t.bigint "recipient_id"
    t.bigint "question_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "answers_target"
    t.jsonb "score"
    t.jsonb "score_target"
    t.jsonb "answers_target_additional"
    t.index ["answers_target"], name: "index_submission_answers_on_answers_target", using: :gin
    t.index ["answers_target_additional"], name: "index_submission_answers_on_answers_target_additional", using: :gin
    t.index ["category_id"], name: "index_submission_answers_on_category_id"
    t.index ["question_id"], name: "index_submission_answers_on_question_id"
    t.index ["recipient_id"], name: "index_submission_answers_on_recipient_id"
    t.index ["score"], name: "index_submission_answers_on_score", using: :gin
    t.index ["score_target"], name: "index_submission_answers_on_score_target", using: :gin
    t.index ["submission_id"], name: "index_submission_answers_on_submission_id"
    t.index ["survey_id"], name: "index_submission_answers_on_survey_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.bigint "total_time", default: 0
    t.jsonb "submission_category_time_spent"
    t.jsonb "submission_question_time_spent"
    t.jsonb "data_json"
    t.string "gender"
    t.string "gender_image_slug"
    t.string "full_name"
    t.string "decrypted_mail"
    t.integer "survey_eligibility", default: 0
    t.index ["data_json"], name: "index_submissions_on_data_json", using: :gin
    t.index ["recipient_id"], name: "index_submissions_on_recipient_id"
    t.index ["submission_category_time_spent"], name: "index_submissions_on_submission_category_time_spent", using: :gin
    t.index ["submission_question_time_spent"], name: "index_submissions_on_submission_question_time_spent", using: :gin
    t.index ["survey_id"], name: "index_submissions_on_survey_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
    t.string "email_from"
    t.string "email_sender"
    t.string "email_subject"
    t.datetime "delivery_time"
    t.datetime "delivery_start_at"
    t.datetime "delivery_end_at"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "template_theme_id"
    t.text "thank_you_page"
    t.text "welcome_page"
    t.string "survey_token"
    t.integer "survey_state", default: 0
    t.integer "created_by_id"
    t.integer "persona_summary_display_type"
    t.string "public_token"
    t.boolean "get_sharable_link"
    t.datetime "survey_sent_at"
    t.boolean "non_email_link", default: false
    t.boolean "enable_share", default: true
    t.boolean "sendmail_status", default: false
    t.datetime "deleted_at"
    t.boolean "show_descriptions", default: false
    t.integer "survey_type", default: 0
    t.boolean "show_block_name", default: false
    t.string "gender"
    t.string "gender_image_slug"
    t.string "gender_full_name"
    t.index ["template_theme_id"], name: "index_surveys_on_template_theme_id"
  end

  create_table "template_themes", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "thank_you_page"
    t.text "welcome_page"
    t.bigint "account_id"
    t.boolean "default_template", default: false
    t.string "template_type"
    t.index ["account_id"], name: "index_template_themes_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "invitation_code"
    t.integer "role"
    t.integer "active", default: 0
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "admin_account_id"
    t.index ["account_id"], name: "index_users_on_account_id"
  end

  add_foreign_key "account_settings", "accounts"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "custom_personas", "accounts"
  add_foreign_key "custom_personas", "groups"
  add_foreign_key "custom_personas", "surveys"
  add_foreign_key "groups", "accounts"
  add_foreign_key "lists", "accounts"
  add_foreign_key "question_labels", "label_templates"
  add_foreign_key "question_labels", "questions"
  add_foreign_key "questions", "accounts"
  add_foreign_key "questions", "categories"
  add_foreign_key "recipients", "accounts"
  add_foreign_key "submission_answers", "categories"
  add_foreign_key "submission_answers", "questions"
  add_foreign_key "submission_answers", "recipients"
  add_foreign_key "submission_answers", "submissions"
  add_foreign_key "submission_answers", "surveys"
  add_foreign_key "submissions", "recipients"
  add_foreign_key "submissions", "surveys"
  add_foreign_key "surveys", "template_themes"
  add_foreign_key "template_themes", "accounts"
  add_foreign_key "users", "accounts"
end
