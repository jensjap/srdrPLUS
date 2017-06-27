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

ActiveRecord::Schema.define(version: 20170621184411) do

  create_table "approvals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "approvable_type"
    t.integer  "approvable_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["active"], name: "index_approvals_on_active", using: :btree
    t.index ["approvable_type", "approvable_id", "user_id", "active"], name: "index_approvals_on_type_id_user_id_active_uniq", unique: true, using: :btree
    t.index ["approvable_type", "approvable_id", "user_id", "deleted_at"], name: "index_approvals_on_type_id_user_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["approvable_type", "approvable_id"], name: "index_approvals_on_approvable_type_and_approvable_id", using: :btree
    t.index ["deleted_at"], name: "index_approvals_on_deleted_at", using: :btree
    t.index ["user_id"], name: "index_approvals_on_user_id", using: :btree
  end

  create_table "degrees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_degrees_on_deleted_at", using: :btree
    t.index ["name"], name: "index_degrees_on_name", unique: true, using: :btree
  end

  create_table "degrees_profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "degree_id"
    t.integer  "profile_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_degrees_profiles_on_active", using: :btree
    t.index ["degree_id", "profile_id", "active"], name: "index_dp_on_d_id_p_id_active_uniq", unique: true, using: :btree
    t.index ["degree_id", "profile_id", "deleted_at"], name: "index_dp_on_d_id_p_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["degree_id"], name: "index_degrees_profiles_on_degree_id", using: :btree
    t.index ["deleted_at"], name: "index_degrees_profiles_on_deleted_at", using: :btree
    t.index ["profile_id"], name: "index_degrees_profiles_on_profile_id", using: :btree
  end

  create_table "dispatches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "dispatchable_type"
    t.integer  "dispatchable_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["active"], name: "index_dispatches_on_active", using: :btree
    t.index ["deleted_at"], name: "index_dispatches_on_deleted_at", using: :btree
    t.index ["dispatchable_type", "dispatchable_id"], name: "index_dispatches_on_dispatchable_type_and_dispatchable_id", using: :btree
    t.index ["user_id"], name: "index_dispatches_on_user_id", using: :btree
  end

  create_table "extraction_forms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_on_deleted_at", using: :btree
    t.index ["name"], name: "index_extraction_forms_on_name", unique: true, using: :btree
  end

  create_table "extraction_forms_project_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_project_types_on_deleted_at", using: :btree
    t.index ["name"], name: "index_extraction_forms_project_types_on_name", unique: true, using: :btree
  end

  create_table "extraction_forms_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_form_id"
    t.integer  "extraction_forms_project_type_id"
    t.integer  "project_id"
    t.boolean  "public",                           default: false
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["active"], name: "index_extraction_forms_projects_on_active", using: :btree
    t.index ["deleted_at"], name: "index_extraction_forms_projects_on_deleted_at", using: :btree
    t.index ["extraction_form_id", "project_id", "active"], name: "index_efp_on_ef_id_p_id_active", using: :btree
    t.index ["extraction_form_id", "project_id", "deleted_at"], name: "index_efp_on_ef_id_p_id_deleted_at", using: :btree
    t.index ["extraction_form_id"], name: "index_efp_on_ef_id", using: :btree
    t.index ["extraction_forms_project_type_id"], name: "index_efp_on_efpt_id", using: :btree
    t.index ["project_id"], name: "index_efp_on_p_id", using: :btree
  end

  create_table "extraction_forms_projects_section_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_projects_section_types_on_deleted_at", using: :btree
    t.index ["name"], name: "index_extraction_forms_projects_section_types_on_name", unique: true, using: :btree
  end

  create_table "extraction_forms_projects_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_forms_project_id"
    t.integer  "extraction_forms_projects_section_type_id"
    t.integer  "section_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["active"], name: "index_extraction_forms_projects_sections_on_active", using: :btree
    t.index ["deleted_at"], name: "index_extraction_forms_projects_sections_on_deleted_at", using: :btree
    t.index ["extraction_forms_project_id", "section_id", "active"], name: "index_efps_on_ef_id_s_id_active", using: :btree
    t.index ["extraction_forms_project_id", "section_id", "deleted_at"], name: "index_efps_on_ef_id_s_id_deleted_at", using: :btree
    t.index ["extraction_forms_project_id"], name: "index_efps_on_efp_id", using: :btree
    t.index ["extraction_forms_projects_section_type_id"], name: "index_efps_on_efpst_id", using: :btree
    t.index ["section_id"], name: "index_efps_on_s_id", using: :btree
  end

  create_table "frequencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_frequencies_on_deleted_at", using: :btree
  end

  create_table "key_questions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_key_questions_on_deleted_at", using: :btree
    t.index ["name"], name: "index_key_questions_on_name", unique: true, using: :btree
  end

  create_table "key_questions_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_forms_projects_section_id"
    t.integer  "key_question_id"
    t.integer  "project_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["active"], name: "index_key_questions_projects_on_active", using: :btree
    t.index ["deleted_at"], name: "index_key_questions_projects_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id", "key_question_id", "project_id", "active"], name: "index_kqp_on_efps_id_kq_id_p_id_active", using: :btree
    t.index ["extraction_forms_projects_section_id", "key_question_id", "project_id", "deleted_at"], name: "index_kqp_on_efps_id_kq_id_p_id_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_kqp_on_efps_id", using: :btree
    t.index ["key_question_id", "project_id", "active"], name: "index_kqp_on_kq_id_p_id_active", using: :btree
    t.index ["key_question_id", "project_id", "deleted_at"], name: "index_kqp_on_kq_id_p_id_deleted_at", using: :btree
    t.index ["key_question_id"], name: "index_kqp_on_kq_id", using: :btree
    t.index ["project_id"], name: "index_kqp_on_p_id", using: :btree
  end

  create_table "message_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "frequency_id"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["deleted_at"], name: "index_message_types_on_deleted_at", using: :btree
    t.index ["frequency_id"], name: "index_message_types_on_frequency_id", using: :btree
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "message_type_id"
    t.string   "name"
    t.text     "description",     limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["deleted_at"], name: "index_messages_on_deleted_at", using: :btree
    t.index ["message_type_id"], name: "index_messages_on_message_type_id", using: :btree
  end

  create_table "orderings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "orderable_type"
    t.integer  "orderable_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["active"], name: "index_orderings_on_active", using: :btree
    t.index ["deleted_at"], name: "index_orderings_on_deleted_at", using: :btree
    t.index ["orderable_type", "orderable_id", "active"], name: "index_orderings_on_type_id_active_uniq", unique: true, using: :btree
    t.index ["orderable_type", "orderable_id", "deleted_at"], name: "index_orderings_on_type_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["orderable_type", "orderable_id"], name: "index_orderings_on_orderable_type_and_orderable_id", using: :btree
  end

  create_table "organizations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at", using: :btree
    t.index ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  end

  create_table "profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "time_zone",       default: "UTC"
    t.string   "username"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.datetime "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["deleted_at"], name: "index_profiles_on_deleted_at", using: :btree
    t.index ["organization_id"], name: "index_profiles_on_organization_id", using: :btree
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true, using: :btree
    t.index ["username"], name: "index_profiles_on_username", unique: true, using: :btree
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description",             limit: 65535
    t.text     "attribution",             limit: 65535
    t.text     "methodology_description", limit: 65535
    t.string   "prospero"
    t.string   "doi"
    t.text     "notes",                   limit: 65535
    t.string   "funding_source"
    t.datetime "deleted_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["deleted_at"], name: "index_projects_on_deleted_at", using: :btree
  end

  create_table "publishings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "publishable_type"
    t.integer  "publishable_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["active"], name: "index_publishings_on_active", using: :btree
    t.index ["deleted_at"], name: "index_publishings_on_deleted_at", using: :btree
    t.index ["publishable_type", "publishable_id", "user_id", "active"], name: "index_publishings_on_type_id_user_id_active_uniq", unique: true, using: :btree
    t.index ["publishable_type", "publishable_id", "user_id", "deleted_at"], name: "index_publishings_on_type_id_user_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["publishable_type", "publishable_id"], name: "index_publishings_on_publishable_type_and_publishable_id", using: :btree
    t.index ["user_id"], name: "index_publishings_on_user_id", using: :btree
  end

  create_table "question_row_column_field_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_row_column_field_id"
    t.string   "key",                          null: false
    t.string   "value",                        null: false
    t.string   "value_type"
    t.datetime "deleted_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["deleted_at"], name: "index_question_row_column_field_options_on_deleted_at", using: :btree
    t.index ["question_row_column_field_id", "deleted_at"], name: "index_qrcfo_on_qrcf_id_deleted_at", using: :btree
    t.index ["question_row_column_field_id"], name: "index_qrcfo_on_qrcf_id", using: :btree
  end

  create_table "question_row_column_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_row_column_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["deleted_at"], name: "index_question_row_column_fields_on_deleted_at", using: :btree
    t.index ["question_row_column_id"], name: "index_qrcf_on_qrc_id", using: :btree
  end

  create_table "question_row_columns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_row_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["deleted_at"], name: "index_question_row_columns_on_deleted_at", using: :btree
    t.index ["question_row_id", "deleted_at"], name: "index_qrc_on_qr_id_deleted_at", using: :btree
    t.index ["question_row_id"], name: "index_question_row_columns_on_question_row_id", using: :btree
  end

  create_table "question_rows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["deleted_at"], name: "index_question_rows_on_deleted_at", using: :btree
    t.index ["question_id", "deleted_at"], name: "index_qr_on_q_id_deleted_at", using: :btree
    t.index ["question_id"], name: "index_question_rows_on_question_id", using: :btree
  end

  create_table "question_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_types_on_deleted_at", using: :btree
  end

  create_table "questions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_type_id"
    t.integer  "extraction_forms_projects_section_id"
    t.string   "name"
    t.text     "description",                          limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.index ["deleted_at"], name: "index_questions_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_questions_on_extraction_forms_projects_section_id", using: :btree
    t.index ["question_type_id", "extraction_forms_projects_section_id", "deleted_at"], name: "index_q_on_qt_id_efps_id_deleted_at", using: :btree
    t.index ["question_type_id"], name: "index_questions_on_question_type_id", using: :btree
  end

  create_table "sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.boolean  "default",    default: false
    t.datetime "deleted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["default"], name: "index_sections_on_default", using: :btree
    t.index ["deleted_at"], name: "index_sections_on_deleted_at", using: :btree
    t.index ["name"], name: "index_sections_on_name", unique: true, using: :btree
  end

  create_table "suggestions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "suggestable_type"
    t.integer  "suggestable_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["active"], name: "index_suggestions_on_active", using: :btree
    t.index ["deleted_at"], name: "index_suggestions_on_deleted_at", using: :btree
    t.index ["suggestable_type", "suggestable_id", "user_id", "active"], name: "index_suggestions_on_type_id_user_id_active_uniq", unique: true, using: :btree
    t.index ["suggestable_type", "suggestable_id", "user_id", "deleted_at"], name: "index_suggestions_on_type_id_user_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["suggestable_type", "suggestable_id"], name: "index_suggestions_on_suggestable_type_and_suggestable_id", using: :btree
    t.index ["user_id"], name: "index_suggestions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "deleted_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "version_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
    t.index ["version_id"], name: "index_version_associations_on_version_id", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 4294967295
    t.integer  "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
    t.index ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree
  end

  add_foreign_key "approvals", "users"
  add_foreign_key "degrees_profiles", "degrees"
  add_foreign_key "degrees_profiles", "profiles"
  add_foreign_key "dispatches", "users"
  add_foreign_key "extraction_forms_projects", "extraction_forms"
  add_foreign_key "extraction_forms_projects", "extraction_forms_project_types"
  add_foreign_key "extraction_forms_projects", "projects"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_section_types"
  add_foreign_key "extraction_forms_projects_sections", "sections"
  add_foreign_key "key_questions_projects", "extraction_forms_projects_sections"
  add_foreign_key "key_questions_projects", "key_questions"
  add_foreign_key "key_questions_projects", "projects"
  add_foreign_key "message_types", "frequencies"
  add_foreign_key "messages", "message_types"
  add_foreign_key "profiles", "organizations"
  add_foreign_key "profiles", "users"
  add_foreign_key "publishings", "users"
  add_foreign_key "question_row_column_field_options", "question_row_column_fields"
  add_foreign_key "question_row_column_fields", "question_row_columns"
  add_foreign_key "question_row_columns", "question_rows"
  add_foreign_key "question_rows", "questions"
  add_foreign_key "questions", "extraction_forms_projects_sections"
  add_foreign_key "questions", "question_types"
  add_foreign_key "suggestions", "users"
end
