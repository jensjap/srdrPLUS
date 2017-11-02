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

ActiveRecord::Schema.define(version: 20171031043418) do

  create_table "action_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "action_type_id"
    t.string   "actionable_type"
    t.integer  "actionable_id"
    t.integer  "action_count"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["action_type_id"], name: "index_actions_on_action_type_id", using: :btree
    t.index ["actionable_type", "actionable_id"], name: "index_actions_on_actionable_type_and_actionable_id", using: :btree
    t.index ["user_id"], name: "index_actions_on_user_id", using: :btree
  end

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

  create_table "assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.integer  "done_so_far"
    t.datetime "date_assigned"
    t.datetime "date_due"
    t.integer  "done"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["task_id"], name: "index_assignments_on_task_id", using: :btree
    t.index ["user_id"], name: "index_assignments_on_user_id", using: :btree
  end

  create_table "authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citation_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["citation_id"], name: "index_authors_on_citation_id", using: :btree
  end

  create_table "citation_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "citations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citation_type_id"
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "refman"
    t.string   "pmid"
    t.binary   "abstract",         limit: 65535
    t.index ["citation_type_id"], name: "index_citations_on_citation_type_id", using: :btree
  end

  create_table "citations_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citation_id"
    t.integer  "project_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "consensus_type_id"
    t.boolean  "pilot_flag"
    t.index ["citation_id"], name: "index_citations_projects_on_citation_id", using: :btree
    t.index ["consensus_type_id"], name: "index_citations_projects_on_consensus_type_id", using: :btree
    t.index ["project_id"], name: "index_citations_projects_on_project_id", using: :btree
  end

  create_table "consensus_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "dependencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "dependable_type"
    t.integer  "dependable_id"
    t.string   "prerequisitable_type"
    t.integer  "prerequisitable_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["active"], name: "index_dependencies_on_active", using: :btree
    t.index ["deleted_at"], name: "index_dependencies_on_deleted_at", using: :btree
    t.index ["dependable_type", "dependable_id", "prerequisitable_type", "prerequisitable_id", "active"], name: "index_dependencies_on_dtype_did_ptype_pid_active_uniq", unique: true, using: :btree
    t.index ["dependable_type", "dependable_id", "prerequisitable_type", "prerequisitable_id", "deleted_at"], name: "index_dependencies_on_dtype_did_ptype_pid_deleted_at_uniq", unique: true, using: :btree
    t.index ["dependable_type", "dependable_id"], name: "index_dependencies_on_dtype_did", using: :btree
    t.index ["prerequisitable_type", "prerequisitable_id"], name: "index_dependencies_on_ptype_pid", using: :btree
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

  create_table "eefps_qrcf", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extractions_extraction_forms_projects_section_id"
    t.integer  "question_row_column_field_id"
    t.text     "name",                                             limit: 65535
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["active"], name: "index_eefps_qrcf_on_active", using: :btree
    t.index ["deleted_at"], name: "index_eefps_qrcf_on_deleted_at", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id", "question_row_column_field_id", "active"], name: "index_eefpsqrcf_on_eefps_id_qrcf_id_active", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id", "question_row_column_field_id", "deleted_at"], name: "index_eefpsqrcf_on_eefps_id_qrcf_id_deleted_at", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefpsqrcf_on_eefps_id", using: :btree
    t.index ["question_row_column_field_id"], name: "index_eefpsqrcf_on_qrcf_id", using: :btree
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
    t.integer  "extraction_forms_project_type_id"
    t.integer  "extraction_form_id"
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
    t.index ["extraction_forms_project_type_id", "extraction_form_id", "project_id", "active"], name: "index_efp_on_efpt_id_ef_id_p_id_active", using: :btree
    t.index ["extraction_forms_project_type_id", "extraction_form_id", "project_id", "deleted_at"], name: "index_efp_on_efpt_id_ef_id_p_id_deleted_at", using: :btree
    t.index ["extraction_forms_project_type_id"], name: "index_efp_on_efpt_id", using: :btree
    t.index ["project_id"], name: "index_efp_on_p_id", using: :btree
  end

  create_table "extraction_forms_projects_section_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_forms_projects_section_id"
    t.boolean  "by_type1"
    t.boolean  "include_total"
    t.datetime "deleted_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["deleted_at"], name: "index_efpso_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id", "deleted_at"], name: "index_efpso_on_efps_id_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_efpso_on_efps_id", using: :btree
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
    t.integer  "extraction_forms_projects_section_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["active"], name: "index_extraction_forms_projects_sections_on_active", using: :btree
    t.index ["deleted_at"], name: "index_extraction_forms_projects_sections_on_deleted_at", using: :btree
    t.index ["extraction_forms_project_id", "extraction_forms_projects_section_type_id", "section_id", "extraction_forms_projects_section_id", "active"], name: "index_efps_on_efp_id_efpst_id_s_id_efps_id_active", using: :btree
    t.index ["extraction_forms_project_id", "extraction_forms_projects_section_type_id", "section_id", "extraction_forms_projects_section_id", "deleted_at"], name: "index_efps_on_efp_id_efpst_id_s_id_efps_id_deleted_at", using: :btree
    t.index ["extraction_forms_project_id"], name: "index_efps_on_efp_id", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_efps_on_efps_id", using: :btree
    t.index ["extraction_forms_projects_section_type_id"], name: "index_efps_on_efpst_id", using: :btree
    t.index ["section_id"], name: "index_efps_on_s_id", using: :btree
  end

  create_table "extractions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "projects_study_id"
    t.integer  "projects_users_role_id"
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["deleted_at"], name: "index_extractions_on_deleted_at", using: :btree
    t.index ["projects_study_id", "projects_users_role_id", "deleted_at"], name: "index_e_on_ps_id_pur_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["projects_study_id"], name: "index_extractions_on_projects_study_id", using: :btree
    t.index ["projects_users_role_id"], name: "index_extractions_on_projects_users_role_id", using: :btree
  end

  create_table "extractions_extraction_forms_projects_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_id"
    t.integer  "extraction_forms_projects_section_id"
    t.integer  "extractions_extraction_forms_projects_section_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["active"], name: "index_eefps_on_active", using: :btree
    t.index ["deleted_at"], name: "index_eefps_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_eefps_on_efps_id", using: :btree
    t.index ["extraction_id", "extraction_forms_projects_section_id", "extractions_extraction_forms_projects_section_id", "active"], name: "index_eefps_on_e_id_efps_id_eefps_id_active", using: :btree
    t.index ["extraction_id", "extraction_forms_projects_section_id", "extractions_extraction_forms_projects_section_id", "deleted_at"], name: "index_eefps_on_e_id_efps_id_eefps_id_deleted_at", using: :btree
    t.index ["extraction_id"], name: "index_eefps_on_e_id", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefps_on_eefps_id", using: :btree
  end

  create_table "extractions_extraction_forms_projects_sections_type1s", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extractions_extraction_forms_projects_section_id"
    t.integer  "type1_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["active"], name: "index_eefpst1_on_active", using: :btree
    t.index ["deleted_at"], name: "index_eefpst1_on_deleted_at", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id", "type1_id", "active"], name: "index_eefpst1_on_eefps_id_t1_id_active", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id", "type1_id", "deleted_at"], name: "index_eefpst1_on_eefps_id_t1_id_deleted_at", using: :btree
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefpst1_on_eefps_id", using: :btree
    t.index ["type1_id"], name: "index_eefpst1_on_t1_id", using: :btree
  end

  create_table "extractions_key_questions_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_id"
    t.integer  "key_questions_project_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["active"], name: "index_ekqp_on_active", using: :btree
    t.index ["deleted_at"], name: "index_ekqp_on_deleted_at", using: :btree
    t.index ["extraction_id", "key_questions_project_id", "active"], name: "index_ekqp_on_e_id_kqp_id_active", using: :btree
    t.index ["extraction_id", "key_questions_project_id", "deleted_at"], name: "index_ekqp_on_e_id_kqp_id_deleted_at", using: :btree
    t.index ["extraction_id"], name: "index_ekqp_on_e_id", using: :btree
    t.index ["key_questions_project_id"], name: "index_ekqp_on_kqp_id", using: :btree
  end

  create_table "extractions_projects_users_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_id"
    t.integer  "projects_users_role_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["active"], name: "index_epur_on_active", using: :btree
    t.index ["deleted_at"], name: "index_epur_on_deleted_at", using: :btree
    t.index ["extraction_id", "projects_users_role_id", "active"], name: "index_epur_on_e_id_pur_id_active_uniq", unique: true, using: :btree
    t.index ["extraction_id", "projects_users_role_id", "deleted_at"], name: "index_epur_on_e_id_pur_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["extraction_id"], name: "index_epur_on_e_id", using: :btree
    t.index ["projects_users_role_id"], name: "index_epur_on_pur_id", using: :btree
  end

  create_table "frequencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_frequencies_on_deleted_at", using: :btree
  end

  create_table "journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citation_id"
    t.integer  "volume"
    t.integer  "issue"
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.date     "publication_date"
    t.index ["citation_id"], name: "index_journals_on_citation_id", using: :btree
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

  create_table "keywords", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citation_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["citation_id"], name: "index_keywords_on_citation_id", using: :btree
  end

  create_table "labels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citations_project_id"
    t.integer  "user_id"
    t.integer  "value"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["citations_project_id"], name: "index_labels_on_citations_project_id", using: :btree
    t.index ["user_id"], name: "index_labels_on_user_id", using: :btree
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

  create_table "notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "notable_type"
    t.integer  "notable_id"
    t.text     "value",        limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id", using: :btree
    t.index ["user_id"], name: "index_notes_on_user_id", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "resource_owner_id",               null: false
    t.integer  "application_id",                  null: false
    t.string   "token",                           null: false
    t.integer  "expires_in",                      null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["application_id"], name: "fk_rails_b4b53e07b8", using: :btree
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "fk_rails_732cb83ab7", using: :btree
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                    null: false
    t.string   "uid",                                     null: false
    t.string   "secret",                                  null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.string   "scopes",                     default: "", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
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

  create_table "predictions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citations_project_id"
    t.integer  "value"
    t.integer  "num_yes_votes"
    t.float    "predicted_probability", limit: 24
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["citations_project_id"], name: "index_predictions_on_citations_project_id", using: :btree
  end

  create_table "priorities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "citations_project_id"
    t.integer  "value"
    t.integer  "num_times_labeled"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["citations_project_id"], name: "index_priorities_on_citations_project_id", using: :btree
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

  create_table "projects_studies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id"
    t.integer  "study_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_ps_on_active", using: :btree
    t.index ["deleted_at"], name: "index_ps_on_deleted_at", using: :btree
    t.index ["project_id", "study_id", "active"], name: "index_ps_on_p_id_s_id_active", using: :btree
    t.index ["project_id", "study_id", "deleted_at"], name: "index_ps_on_p_id_s_id_deleted_at", using: :btree
    t.index ["project_id"], name: "index_projects_studies_on_project_id", using: :btree
    t.index ["study_id"], name: "index_projects_studies_on_study_id", using: :btree
  end

  create_table "projects_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_projects_users_on_active", using: :btree
    t.index ["deleted_at"], name: "index_projects_users_on_deleted_at", using: :btree
    t.index ["project_id", "user_id", "active"], name: "index_pu_on_p_id_u_id_active_uniq", unique: true, using: :btree
    t.index ["project_id", "user_id", "deleted_at"], name: "index_pu_on_p_id_u_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["project_id"], name: "index_projects_users_on_project_id", using: :btree
    t.index ["user_id"], name: "index_projects_users_on_user_id", using: :btree
  end

  create_table "projects_users_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "projects_user_id"
    t.integer  "role_id"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["active"], name: "index_projects_users_roles_on_active", using: :btree
    t.index ["deleted_at"], name: "index_projects_users_roles_on_deleted_at", using: :btree
    t.index ["projects_user_id", "role_id", "active"], name: "index_pur_on_pu_id_r_id_active_uniq", unique: true, using: :btree
    t.index ["projects_user_id", "role_id", "deleted_at"], name: "index_pur_on_pu_id_r_id_deleted_at_uniq", unique: true, using: :btree
    t.index ["projects_user_id"], name: "index_projects_users_roles_on_projects_user_id", using: :btree
    t.index ["role_id"], name: "index_projects_users_roles_on_role_id", using: :btree
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
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_row_column_field_options_on_deleted_at", using: :btree
  end

  create_table "question_row_column_field_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_row_column_field_types_on_deleted_at", using: :btree
  end

  create_table "question_row_column_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_row_column_id"
    t.integer  "question_row_column_field_type_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["deleted_at"], name: "index_question_row_column_fields_on_deleted_at", using: :btree
    t.index ["question_row_column_field_type_id"], name: "index_qrcf_on_qrcft_id", using: :btree
    t.index ["question_row_column_id"], name: "index_qrcf_on_qrc_id", using: :btree
  end

  create_table "question_row_column_fields_question_row_column_field_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "question_row_column_field_id"
    t.integer  "question_row_column_field_option_id"
    t.string   "name"
    t.string   "name_type"
    t.datetime "deleted_at"
    t.boolean  "active"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["active"], name: "index_qrcfqrcfo_on_active", using: :btree
    t.index ["deleted_at"], name: "index_qrcfqrcfo_on_deleted_at", using: :btree
    t.index ["question_row_column_field_id", "question_row_column_field_option_id", "active"], name: "index_qrcfqrcfo_on_qrcf_id_qrcfo_id_active", using: :btree
    t.index ["question_row_column_field_id", "question_row_column_field_option_id", "deleted_at"], name: "index_qrcfqrcfo_on_qrcf_id_qrcfo_id_deleted_at", using: :btree
    t.index ["question_row_column_field_id"], name: "index_qrcfqrcfo_on_qrcf_id", using: :btree
    t.index ["question_row_column_field_option_id"], name: "index_qrcfqrcfo_on_qrcfo_id", using: :btree
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

  create_table "questions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_forms_projects_section_id"
    t.string   "name"
    t.text     "description",                          limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.index ["deleted_at"], name: "index_questions_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id", "deleted_at"], name: "index_q_on_efps_id_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_questions_on_extraction_forms_projects_section_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_roles_on_deleted_at", using: :btree
    t.index ["name"], name: "index_roles_on_name", unique: true, using: :btree
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

  create_table "studies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id", using: :btree
    t.index ["user_id"], name: "index_taggings_on_user_id", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "task_type_id"
    t.integer  "num_assigned"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "project_id"
    t.index ["project_id"], name: "index_tasks_on_project_id", using: :btree
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id", using: :btree
  end

  create_table "type1s", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "extraction_forms_projects_section_id"
    t.string   "name"
    t.text     "description",                          limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.index ["deleted_at"], name: "index_type1s_on_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id", "deleted_at"], name: "index_t1_on_efps_id_deleted_at", using: :btree
    t.index ["extraction_forms_projects_section_id"], name: "index_type1s_on_extraction_forms_projects_section_id", using: :btree
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

  add_foreign_key "actions", "action_types"
  add_foreign_key "actions", "users"
  add_foreign_key "approvals", "users"
  add_foreign_key "assignments", "tasks"
  add_foreign_key "assignments", "users"
  add_foreign_key "authors", "citations"
  add_foreign_key "citations", "citation_types"
  add_foreign_key "citations_projects", "citations"
  add_foreign_key "citations_projects", "consensus_types"
  add_foreign_key "citations_projects", "projects"
  add_foreign_key "degrees_profiles", "degrees"
  add_foreign_key "degrees_profiles", "profiles"
  add_foreign_key "dispatches", "users"
  add_foreign_key "eefps_qrcf", "extractions_extraction_forms_projects_sections"
  add_foreign_key "eefps_qrcf", "question_row_column_fields"
  add_foreign_key "extraction_forms_projects", "extraction_forms"
  add_foreign_key "extraction_forms_projects", "extraction_forms_project_types"
  add_foreign_key "extraction_forms_projects", "projects"
  add_foreign_key "extraction_forms_projects_section_options", "extraction_forms_projects_sections"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_section_types"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_sections"
  add_foreign_key "extraction_forms_projects_sections", "sections"
  add_foreign_key "extractions", "projects_studies"
  add_foreign_key "extractions", "projects_users_roles"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extractions"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extractions_extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "extractions_extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1s"
  add_foreign_key "extractions_key_questions_projects", "extractions"
  add_foreign_key "extractions_key_questions_projects", "key_questions_projects"
  add_foreign_key "extractions_projects_users_roles", "extractions"
  add_foreign_key "extractions_projects_users_roles", "projects_users_roles"
  add_foreign_key "journals", "citations"
  add_foreign_key "key_questions_projects", "extraction_forms_projects_sections"
  add_foreign_key "key_questions_projects", "key_questions"
  add_foreign_key "key_questions_projects", "projects"
  add_foreign_key "keywords", "citations"
  add_foreign_key "labels", "citations_projects"
  add_foreign_key "labels", "users"
  add_foreign_key "message_types", "frequencies"
  add_foreign_key "messages", "message_types"
  add_foreign_key "notes", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "predictions", "citations_projects"
  add_foreign_key "priorities", "citations_projects"
  add_foreign_key "profiles", "organizations"
  add_foreign_key "profiles", "users"
  add_foreign_key "projects_studies", "projects"
  add_foreign_key "projects_studies", "studies"
  add_foreign_key "projects_users", "projects"
  add_foreign_key "projects_users", "users"
  add_foreign_key "projects_users_roles", "projects_users"
  add_foreign_key "projects_users_roles", "roles"
  add_foreign_key "publishings", "users"
  add_foreign_key "question_row_column_fields", "question_row_column_field_types"
  add_foreign_key "question_row_column_fields", "question_row_columns"
  add_foreign_key "question_row_column_fields_question_row_column_field_options", "question_row_column_field_options"
  add_foreign_key "question_row_column_fields_question_row_column_field_options", "question_row_column_fields"
  add_foreign_key "question_row_columns", "question_rows"
  add_foreign_key "question_rows", "questions"
  add_foreign_key "questions", "extraction_forms_projects_sections"
  add_foreign_key "suggestions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "taggings", "users"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "task_types"
  add_foreign_key "type1s", "extraction_forms_projects_sections"
end
