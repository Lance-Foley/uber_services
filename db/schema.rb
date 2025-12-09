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

ActiveRecord::Schema[8.1].define(version: 2025_12_09_205150) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "connected_services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider", "uid"], name: "index_connected_services_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_connected_services_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.bigint "job_request_id"
    t.datetime "last_message_at"
    t.bigint "participant_one_id", null: false
    t.bigint "participant_two_id", null: false
    t.datetime "updated_at", null: false
    t.index ["job_request_id"], name: "index_conversations_on_job_request_id"
    t.index ["participant_one_id", "participant_two_id"], name: "idx_on_participant_one_id_participant_two_id_34e343b89f", unique: true
    t.index ["participant_one_id"], name: "index_conversations_on_participant_one_id"
    t.index ["participant_two_id"], name: "index_conversations_on_participant_two_id"
  end

  create_table "device_tokens", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "device_id"
    t.string "platform"
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_device_tokens_on_user_id"
  end

  create_table "job_bids", force: :cascade do |t|
    t.decimal "bid_amount", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "estimated_arrival"
    t.integer "estimated_duration_minutes"
    t.bigint "job_request_id", null: false
    t.text "message"
    t.bigint "provider_id", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["job_request_id", "provider_id"], name: "index_job_bids_on_job_request_id_and_provider_id", unique: true
    t.index ["job_request_id"], name: "index_job_bids_on_job_request_id"
    t.index ["provider_id"], name: "index_job_bids_on_provider_id"
  end

  create_table "job_requests", force: :cascade do |t|
    t.datetime "accepted_at"
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.bigint "cancelled_by_id"
    t.datetime "completed_at"
    t.bigint "consumer_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "estimated_price", precision: 8, scale: 2
    t.decimal "final_price", precision: 8, scale: 2
    t.boolean "flexible_timing", default: false
    t.jsonb "metadata", default: {}
    t.decimal "platform_fee", precision: 8, scale: 2
    t.decimal "platform_fee_percentage", precision: 5, scale: 2, default: "15.0"
    t.bigint "property_id", null: false
    t.bigint "provider_id"
    t.decimal "provider_payout", precision: 8, scale: 2
    t.datetime "requested_date", null: false
    t.datetime "requested_time_end"
    t.datetime "requested_time_start"
    t.bigint "service_type_id", null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "urgency", default: 0
    t.index ["cancelled_by_id"], name: "index_job_requests_on_cancelled_by_id"
    t.index ["consumer_id", "status"], name: "index_job_requests_on_consumer_id_and_status"
    t.index ["consumer_id"], name: "index_job_requests_on_consumer_id"
    t.index ["property_id"], name: "index_job_requests_on_property_id"
    t.index ["provider_id", "status"], name: "index_job_requests_on_provider_id_and_status"
    t.index ["provider_id"], name: "index_job_requests_on_provider_id"
    t.index ["requested_date"], name: "index_job_requests_on_requested_date"
    t.index ["service_type_id"], name: "index_job_requests_on_service_type_id"
    t.index ["status"], name: "index_job_requests_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.boolean "read", default: false
    t.datetime "read_at"
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action_url"
    t.text "body"
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.string "notification_type"
    t.boolean "push_sent"
    t.datetime "push_sent_at"
    t.boolean "read"
    t.datetime "read_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "authorized_at"
    t.datetime "captured_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "usd"
    t.text "failure_reason"
    t.bigint "job_request_id", null: false
    t.jsonb "metadata", default: {}
    t.bigint "payee_id", null: false
    t.bigint "payer_id", null: false
    t.decimal "platform_fee", precision: 10, scale: 2
    t.decimal "provider_amount", precision: 10, scale: 2
    t.datetime "refunded_at"
    t.datetime "released_at"
    t.string "status", default: "pending"
    t.string "stripe_charge_id"
    t.string "stripe_payment_intent_id"
    t.string "stripe_transfer_id"
    t.datetime "updated_at", null: false
    t.index ["job_request_id"], name: "index_payments_on_job_request_id"
    t.index ["payee_id"], name: "index_payments_on_payee_id"
    t.index ["payer_id"], name: "index_payments_on_payer_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id"
  end

  create_table "properties", force: :cascade do |t|
    t.boolean "active"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.decimal "driveway_length_ft"
    t.decimal "latitude"
    t.decimal "longitude"
    t.decimal "lot_size_sqft"
    t.string "name"
    t.jsonb "photos"
    t.boolean "primary"
    t.integer "property_size"
    t.text "special_instructions"
    t.string "state"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "zip_code"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.boolean "accepting_jobs"
    t.jsonb "availability_schedule"
    t.decimal "average_rating"
    t.text "bio"
    t.string "business_name"
    t.integer "completed_jobs"
    t.datetime "created_at", null: false
    t.integer "service_radius_miles"
    t.string "stripe_account_id"
    t.string "stripe_account_status"
    t.boolean "stripe_charges_enabled"
    t.boolean "stripe_payouts_enabled"
    t.integer "total_reviews"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified"
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
  end

  create_table "provider_services", force: :cascade do |t|
    t.boolean "active"
    t.decimal "base_price"
    t.datetime "created_at", null: false
    t.decimal "hourly_rate"
    t.decimal "min_charge"
    t.text "notes"
    t.integer "pricing_model"
    t.bigint "provider_profile_id", null: false
    t.bigint "service_type_id", null: false
    t.jsonb "size_pricing"
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_provider_services_on_provider_profile_id"
    t.index ["service_type_id"], name: "index_provider_services_on_service_type_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.boolean "flagged", default: false
    t.bigint "job_request_id", null: false
    t.integer "rating", null: false
    t.datetime "responded_at"
    t.text "response"
    t.bigint "reviewee_id", null: false
    t.bigint "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
    t.index ["job_request_id", "reviewer_id"], name: "index_reviews_on_job_request_id_and_reviewer_id", unique: true
    t.index ["job_request_id"], name: "index_reviews_on_job_request_id"
    t.index ["reviewee_id", "rating"], name: "index_reviews_on_reviewee_id_and_rating"
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "service_categories", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon_name"
    t.string "name"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_service_categories_on_slug", unique: true
  end

  create_table "service_types", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon_name"
    t.string "name"
    t.integer "position"
    t.bigint "service_category_id", null: false
    t.string "slug"
    t.decimal "suggested_max_price"
    t.decimal "suggested_min_price"
    t.datetime "updated_at", null: false
    t.index ["service_category_id"], name: "index_service_types_on_service_category_id"
    t.index ["slug"], name: "index_service_types_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.boolean "admin", default: false, null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "password_digest", null: false
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["latitude", "longitude"], name: "index_users_on_latitude_and_longitude"
  end

  add_foreign_key "connected_services", "users"
  add_foreign_key "conversations", "job_requests"
  add_foreign_key "conversations", "users", column: "participant_one_id"
  add_foreign_key "conversations", "users", column: "participant_two_id"
  add_foreign_key "device_tokens", "users"
  add_foreign_key "job_bids", "job_requests"
  add_foreign_key "job_bids", "users", column: "provider_id"
  add_foreign_key "job_requests", "properties"
  add_foreign_key "job_requests", "service_types"
  add_foreign_key "job_requests", "users", column: "cancelled_by_id"
  add_foreign_key "job_requests", "users", column: "consumer_id"
  add_foreign_key "job_requests", "users", column: "provider_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "job_requests"
  add_foreign_key "payments", "users", column: "payee_id"
  add_foreign_key "payments", "users", column: "payer_id"
  add_foreign_key "properties", "users"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "provider_services", "provider_profiles"
  add_foreign_key "provider_services", "service_types"
  add_foreign_key "reviews", "job_requests"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "service_types", "service_categories"
  add_foreign_key "sessions", "users"
end
