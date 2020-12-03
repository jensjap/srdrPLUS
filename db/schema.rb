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

ActiveRecord::Schema.define(version: 2020_12_01_073722) do

  create_table "abstrackr_settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "profile_id"
    t.boolean "authors_visible", default: true
    t.boolean "journal_visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_abstrackr_settings_on_profile_id"
  end

  create_table "action_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "action_type_id"
    t.string "actionable_type"
    t.integer "actionable_id"
    t.integer "action_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type_id"], name: "index_actions_on_action_type_id"
    t.index ["actionable_type", "actionable_id"], name: "index_actions_on_actionable_type_and_actionable_id"
    t.index ["user_id"], name: "index_actions_on_user_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "add_type_to_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "adverse_event_arms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "adverse_event_id"
    t.integer "arm_id"
    t.integer "num_affected"
    t.integer "num_at_risk"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_event_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_event_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "column_id"
    t.text "value"
    t.integer "adverse_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "arm_id"
    t.index ["adverse_event_id"], name: "StudyData"
  end

  create_table "adverse_event_template_settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_id"
    t.boolean "display_arms"
    t.boolean "display_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "title"
    t.text "description"
    t.index ["extraction_form_id", "study_id"], name: "StudyData"
  end

  create_table "approvals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "approvable_type"
    t.integer "approvable_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_approvals_on_active"
    t.index ["approvable_type", "approvable_id", "user_id", "active"], name: "index_approvals_on_type_id_user_id_active_uniq", unique: true
    t.index ["approvable_type", "approvable_id", "user_id", "deleted_at"], name: "index_approvals_on_type_id_user_id_deleted_at_uniq", unique: true
    t.index ["approvable_type", "approvable_id"], name: "index_approvals_on_approvable_type_and_approvable_id"
    t.index ["deleted_at"], name: "index_approvals_on_deleted_at"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "arm_detail_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "arm_detail_field_id"
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "arm_id", default: 0
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "outcome_id", default: 0
    t.index ["arm_detail_field_id", "study_id"], name: "addp_adix"
    t.index ["arm_detail_field_id"], name: "armdetaildatapoint_armdetailfield_idx"
    t.index ["arm_id"], name: "armdetaildatapoint_arm_idx"
    t.index ["extraction_form_id", "study_id", "arm_detail_field_id", "row_field_id", "column_field_id"], name: "StudyDataRowCol"
    t.index ["extraction_form_id", "study_id", "arm_detail_field_id"], name: "StudyData"
    t.index ["extraction_form_id", "study_id", "arm_id", "arm_detail_field_id", "row_field_id", "column_field_id"], name: "StudyDataCache2"
    t.index ["extraction_form_id", "study_id", "arm_id", "arm_detail_field_id"], name: "StudyDataCache"
    t.index ["extraction_form_id", "study_id", "outcome_id", "arm_detail_field_id"], name: "ReportBuilder0"
    t.index ["extraction_form_id"], name: "armdetaildatapoint_extractionform_idx"
    t.index ["study_id"], name: "armdetaildatapoint_study_idx"
  end

  create_table "arm_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "arm_detail_id"
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.index ["arm_detail_id", "column_number", "row_number"], name: "StudyDataColRow"
    t.index ["arm_detail_id", "column_number"], name: "StudyDataCol"
    t.index ["arm_detail_id", "row_number"], name: "adf_adix"
    t.index ["arm_detail_id"], name: "armdetailfield_armdetail_idx"
  end

  create_table "arm_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "question"
    t.integer "extraction_form_id"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
    t.index ["extraction_form_id", "question_number"], name: "StudyDataSorted"
    t.index ["extraction_form_id", "question_number"], name: "ad_efix"
    t.index ["extraction_form_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "armdetail_extractionform_idx"
  end

  create_table "arms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.string "title"
    t.text "description"
    t.integer "display_number"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_suggested_by_admin", default: false
    t.string "note"
    t.integer "efarm_id"
    t.integer "default_num_enrolled"
    t.boolean "is_intention_to_treat", default: true
    t.index ["extraction_form_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "arm_extractionform_idx"
    t.index ["study_id"], name: "arm_study_idx"
  end

  create_table "assignments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.integer "done_so_far"
    t.datetime "date_assigned"
    t.datetime "date_due"
    t.integer "done"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "projects_users_role_id"
    t.boolean "mutable", default: true
    t.index ["deleted_at"], name: "index_assignments_on_deleted_at"
    t.index ["projects_users_role_id"], name: "index_assignments_on_projects_users_role_id"
    t.index ["task_id"], name: "index_assignments_on_task_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "authors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_authors_on_deleted_at"
  end

  create_table "authors_citations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citation_id", null: false
    t.integer "author_id", null: false
    t.datetime "deleted_at"
    t.index ["citation_id", "author_id"], name: "index_authors_citations_on_citation_id_and_author_id"
    t.index ["deleted_at"], name: "index_authors_citations_on_deleted_at"
  end

  create_table "baseline_characteristic_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "baseline_characteristic_field_id"
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "arm_id", default: 0
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "outcome_id", default: 0
    t.integer "diagnostic_test_id", default: 0
    t.index ["arm_id"], name: "baselinecharacteristicdatapoint_arm_idx"
    t.index ["baseline_characteristic_field_id", "study_id"], name: "bcdp_bcix"
    t.index ["baseline_characteristic_field_id"], name: "baselinecharacteristicdatapoint_baselinefield_idx"
    t.index ["extraction_form_id", "baseline_characteristic_field_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id", "study_id", "arm_id", "baseline_characteristic_field_id", "row_field_id", "column_field_id"], name: "StudyDataCache2"
    t.index ["extraction_form_id", "study_id", "arm_id", "baseline_characteristic_field_id"], name: "StudyDataCache"
    t.index ["extraction_form_id", "study_id", "outcome_id", "baseline_characteristic_field_id"], name: "ReportBuilder1"
    t.index ["extraction_form_id"], name: "baselinecharacteristicdatapoint_extractionform_idx"
    t.index ["study_id"], name: "baselinecharacteristicdatapoint_study_idx"
  end

  create_table "baseline_characteristic_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "baseline_characteristic_id"
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.index ["baseline_characteristic_id", "column_number", "row_number"], name: "StudyDataCache"
    t.index ["baseline_characteristic_id", "row_number"], name: "bcf_bcix"
    t.index ["baseline_characteristic_id"], name: "baselinecharacteristicfield_baselinecharacteristic_idx"
  end

  create_table "baseline_characteristic_subcategory_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "baseline_characteristic_subcategory_field_id"
    t.integer "arm_id"
    t.boolean "is_total"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baseline_characteristic_subcategory_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "subcategory_title"
    t.integer "baseline_characteristic_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baseline_characteristics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "question"
    t.string "field_type"
    t.integer "extraction_form_id"
    t.string "field_notes"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
    t.index ["extraction_form_id", "question_number"], name: "bc_efix"
    t.index ["extraction_form_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "baselinecharacteristic_extractionform_idx"
  end

  create_table "citation_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "citations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "citation_type_id"
    t.string "name", limit: 500, collation: "utf8_general_ci"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refman", collation: "utf8_general_ci"
    t.string "pmid", collation: "utf8_general_ci"
    t.binary "abstract"
    t.integer "page_number_start"
    t.integer "page_number_end"
    t.index ["citation_type_id"], name: "index_citations_on_citation_type_id"
    t.index ["deleted_at"], name: "index_citations_on_deleted_at"
  end

  create_table "citations_keywords", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citation_id", null: false
    t.integer "keyword_id", null: false
    t.index ["citation_id", "keyword_id"], name: "index_citations_keywords_on_citation_id_and_keyword_id"
  end

  create_table "citations_projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citation_id"
    t.integer "project_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "consensus_type_id"
    t.boolean "pilot_flag"
    t.index ["active"], name: "index_citations_projects_on_active"
    t.index ["citation_id"], name: "index_citations_projects_on_citation_id"
    t.index ["consensus_type_id"], name: "index_citations_projects_on_consensus_type_id"
    t.index ["deleted_at"], name: "index_citations_projects_on_deleted_at"
    t.index ["project_id"], name: "index_citations_projects_on_project_id"
  end

  create_table "citations_tasks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citation_id"
    t.integer "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "active"
    t.index ["active"], name: "index_citations_tasks_on_active"
    t.index ["citation_id"], name: "index_citations_tasks_on_citation_id"
    t.index ["deleted_at"], name: "index_citations_tasks_on_deleted_at"
    t.index ["task_id"], name: "index_citations_tasks_on_task_id"
  end

  create_table "color_choices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "hex_code"
    t.string "rgb_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "colorings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "colorable_type"
    t.bigint "colorable_id"
    t.integer "color_choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_choice_id"], name: "index_colorings_on_color_choice_id"
    t.index ["colorable_type", "colorable_id"], name: "index_colorings_on_colorable_type_and_colorable_id"
  end

  create_table "colors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "hex_code"
    t.string "name"
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "comment_text"
    t.integer "commenter_id"
    t.string "fact_or_opinion"
    t.string "post_type"
    t.boolean "is_public"
    t.boolean "is_reply"
    t.integer "reply_to"
    t.text "value_at_comment_time"
    t.boolean "is_flag"
    t.string "flag_type"
    t.boolean "is_high_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "section_name"
    t.integer "section_id"
    t.string "field_name"
    t.integer "study_id"
    t.integer "project_id"
    t.index ["section_id", "section_name", "study_id"], name: "comment_sectionix"
  end

  create_table "comparable_elements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comparable_type"
    t.integer "comparable_id"
    t.datetime "deleted_at"
    t.index ["comparable_type", "comparable_id"], name: "index_comparable_elements_on_comparable_type_and_comparable_id"
    t.index ["deleted_at"], name: "index_comparable_elements_on_deleted_at"
  end

  create_table "comparate_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comparison_id"
    t.datetime "deleted_at"
    t.index ["comparison_id"], name: "index_comparate_groups_on_comparison_id"
    t.index ["deleted_at"], name: "index_comparate_groups_on_deleted_at"
  end

  create_table "comparates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comparate_group_id"
    t.integer "comparable_element_id"
    t.datetime "deleted_at"
    t.index ["comparable_element_id"], name: "index_comparates_on_comparable_element_id"
    t.index ["comparate_group_id"], name: "index_comparates_on_comparate_group_id"
    t.index ["deleted_at"], name: "index_comparates_on_deleted_at"
  end

  create_table "comparators", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "comparison_id"
    t.string "comparator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comparison_id"], name: "EDIT_TAB"
    t.index ["comparison_id"], name: "comparator_comparison_idx"
  end

  create_table "comparison_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "value"
    t.string "footnote"
    t.boolean "is_calculated"
    t.integer "comparison_measure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "comparator_id"
    t.integer "arm_id", default: 0
    t.integer "footnote_number", default: 0
    t.integer "table_cell"
    t.index ["arm_id"], name: "comparisondatapoint_arm_idx"
    t.index ["comparator_id", "comparison_measure_id", "arm_id"], name: "StudyDataCache2"
    t.index ["comparator_id", "comparison_measure_id"], name: "StudyDataCache"
    t.index ["comparator_id"], name: "comparisondatapoint_comparator_idx"
    t.index ["comparison_measure_id", "comparator_id"], name: "EDIT_TAB"
    t.index ["comparison_measure_id"], name: "comparisondatapoint_comparisonmeasure_idx"
  end

  create_table "comparison_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "unit"
    t.string "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "comparison_id"
    t.integer "measure_type", default: 0
    t.index ["comparison_id"], name: "EDIT_TAB"
    t.index ["comparison_id"], name: "comparisonmeasure_comparison_idx"
  end

  create_table "comparisons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "is_anova", default: false, null: false
    t.index ["deleted_at"], name: "index_comparisons_on_deleted_at"
  end

  create_table "comparisons_arms_rssms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "comparison_id"
    t.integer "extractions_extraction_forms_projects_sections_type1_id"
    t.integer "result_statistic_sections_measure_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_comparisons_arms_rssms_on_active"
    t.index ["comparison_id"], name: "index_comparisons_arms_rssms_on_comparison_id"
    t.index ["deleted_at"], name: "index_comparisons_arms_rssms_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_id"], name: "index_comparisons_arms_rssms_on_eefpst_id"
    t.index ["result_statistic_sections_measure_id"], name: "index_comparisons_arms_rssms_on_rssm_id"
  end

  create_table "comparisons_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "measure_id"
    t.integer "comparison_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comparison_id"], name: "index_comparisons_measures_on_comparison_id"
    t.index ["measure_id"], name: "index_comparisons_measures_on_measure_id"
  end

  create_table "comparisons_result_statistic_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "comparison_id"
    t.integer "result_statistic_section_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_comparisons_result_statistic_sections_on_active"
    t.index ["comparison_id", "result_statistic_section_id", "active"], name: "index_crss_on_c_id_rss_id_active"
    t.index ["comparison_id", "result_statistic_section_id", "deleted_at"], name: "index_crss_on_c_id_rss_id_deleted_at"
    t.index ["comparison_id"], name: "index_crss_on_c_id"
    t.index ["deleted_at"], name: "index_comparisons_result_statistic_sections_on_deleted_at"
    t.index ["result_statistic_section_id"], name: "index_crss_on_rss_id"
  end

  create_table "complete_study_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.integer "flagged_by_user"
    t.boolean "is_complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "section_name"
  end

  create_table "consensus_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "counts", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "EFID", default: 0
    t.boolean "ArmD"
    t.bigint "nArmD", default: 0
    t.boolean "OutcomeD"
    t.bigint "nOutcomeD", default: 0
    t.boolean "BaseD"
    t.bigint "nBaseD", default: 0
    t.boolean "DesignD"
    t.bigint "nDesignD", default: 0
    t.boolean "DxTestD"
    t.bigint "nDxTestD", default: 0
    t.bigint "QualityD", default: 0
  end

  create_table "daa_consents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "email"
    t.string "firstName"
    t.string "lastName"
    t.string "qOne"
    t.string "qTwo"
    t.boolean "agree"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "submissionToken"
    t.integer "attempt", default: 0
  end

  create_table "daa_markers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "section"
    t.integer "datapoint_id"
    t.integer "marker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_analysis_levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string "status", default: "pending"
    t.text "message"
    t.datetime "requested_at"
    t.integer "responder_id"
    t.datetime "responded_at"
    t.datetime "last_download_at"
    t.integer "download_count", default: 0
    t.integer "request_count", default: 0
  end

  create_table "default_adverse_event_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "header"
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_cevg_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "results_type"
    t.string "outcome_type"
    t.string "title"
    t.string "description"
    t.string "unit"
    t.integer "measure_type", default: 1
    t.boolean "is_default", default: false
  end

  create_table "default_comparison_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "outcome_type"
    t.string "title"
    t.string "description"
    t.string "unit"
    t.boolean "is_default", default: false
    t.integer "measure_type", default: 0
    t.integer "within_or_between", default: 0
  end

  create_table "default_design_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "column_name"
    t.string "column_description"
    t.string "column_header"
    t.string "outcome_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_comparison_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "column_name"
    t.string "column_description"
    t.string "column_header"
    t.string "outcome_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "outcome_type"
    t.string "title"
    t.string "description"
    t.string "unit"
    t.boolean "is_default", default: false
    t.integer "measure_type", default: 0
  end

  create_table "default_quality_rating_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "rating_item"
    t.integer "display_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "degrees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_degrees_on_deleted_at"
    t.index ["name"], name: "index_degrees_on_name", unique: true
  end

  create_table "degrees_profiles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "degree_id"
    t.integer "profile_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_degrees_profiles_on_active"
    t.index ["degree_id", "profile_id", "active"], name: "index_dp_on_d_id_p_id_active_uniq", unique: true
    t.index ["degree_id", "profile_id", "deleted_at"], name: "index_dp_on_d_id_p_id_deleted_at_uniq", unique: true
    t.index ["degree_id"], name: "index_degrees_profiles_on_degree_id"
    t.index ["deleted_at"], name: "index_degrees_profiles_on_deleted_at"
    t.index ["profile_id"], name: "index_degrees_profiles_on_profile_id"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", limit: 4294967295, null: false
    t.text "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "dependencies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "dependable_type"
    t.integer "dependable_id"
    t.string "prerequisitable_type"
    t.integer "prerequisitable_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_dependencies_on_active"
    t.index ["deleted_at"], name: "index_dependencies_on_deleted_at"
    t.index ["dependable_type", "dependable_id", "prerequisitable_type", "prerequisitable_id", "active"], name: "index_dependencies_on_dtype_did_ptype_pid_active_uniq", unique: true
    t.index ["dependable_type", "dependable_id", "prerequisitable_type", "prerequisitable_id", "deleted_at"], name: "index_dependencies_on_dtype_did_ptype_pid_deleted_at_uniq", unique: true
    t.index ["dependable_type", "dependable_id"], name: "index_dependencies_on_dtype_did"
    t.index ["prerequisitable_type", "prerequisitable_id"], name: "index_dependencies_on_ptype_pid"
  end

  create_table "design_detail_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "design_detail_field_id"
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "arm_id", default: 0
    t.integer "outcome_id", default: 0
    t.index ["design_detail_field_id", "study_id"], name: "dddp_ddix"
    t.index ["design_detail_field_id"], name: "designdetaildatapoint_designfield_idx"
    t.index ["extraction_form_id", "study_id", "design_detail_field_id", "row_field_id", "column_field_id"], name: "StudyDataCache"
    t.index ["extraction_form_id", "study_id", "design_detail_field_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "designdetaildatapoint_extractionform_idx"
    t.index ["study_id"], name: "designdetaildatapoint_study_idx"
  end

  create_table "design_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "design_detail_id"
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.index ["design_detail_id", "column_number", "row_number"], name: "StudyDataColRow"
    t.index ["design_detail_id", "column_number"], name: "StudyDataCol"
    t.index ["design_detail_id", "row_number"], name: "ddf_ddix"
    t.index ["design_detail_id"], name: "designdetailfield_designdetail_idx"
  end

  create_table "design_detail_subcategory_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "design_detail_subcategory_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "study_id"
    t.string "value"
    t.string "notes"
  end

  create_table "design_detail_subcategory_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "subcategory_title"
    t.integer "design_detail_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "design_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "question"
    t.integer "extraction_form_id"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
    t.index ["extraction_form_id", "question_number"], name: "dd_efix"
    t.index ["extraction_form_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "designdetail_extractionform_idx"
  end

  create_table "diagnostic_test_detail_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "diagnostic_test_detail_field_id"
    t.integer "diagnostic_test_id"
  end

  create_table "diagnostic_test_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.integer "diagnostic_test_detail_id"
  end

  create_table "diagnostic_test_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "question"
    t.integer "extraction_form_id"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
  end

  create_table "diagnostic_test_thresholds", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "diagnostic_test_id"
    t.string "threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diagnostic_tests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.integer "test_type"
    t.string "title"
    t.text "description"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dispatches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "dispatchable_type"
    t.integer "dispatchable_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_dispatches_on_active"
    t.index ["deleted_at"], name: "index_dispatches_on_deleted_at"
    t.index ["dispatchable_type", "dispatchable_id"], name: "index_dispatches_on_dispatchable_type_and_dispatchable_id"
    t.index ["user_id"], name: "index_dispatches_on_user_id"
  end

  create_table "eefps_qrcfs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extractions_extraction_forms_projects_sections_type1_id"
    t.integer "extractions_extraction_forms_projects_section_id"
    t.integer "question_row_column_field_id"
    t.text "name"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_eefps_qrcfs_on_active"
    t.index ["deleted_at"], name: "index_eefps_qrcfs_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefpsqrcf_on_eefps_id"
    t.index ["extractions_extraction_forms_projects_sections_type1_id", "extractions_extraction_forms_projects_section_id", "question_row_column_field_id", "active"], name: "index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_active"
    t.index ["extractions_extraction_forms_projects_sections_type1_id", "extractions_extraction_forms_projects_section_id", "question_row_column_field_id", "deleted_at"], name: "index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_id"], name: "index_eefpsqrcf_on_eefpst1_id"
    t.index ["question_row_column_field_id"], name: "index_eefpsqrcf_on_qrcf_id"
  end

  create_table "eefpsqrcf_qrcqrcos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "eefps_qrcf_id"
    t.integer "question_row_columns_question_row_column_option_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_eefpsqrcf_qrcqrcos_on_active"
    t.index ["deleted_at"], name: "index_eefpsqrcf_qrcqrcos_on_deleted_at"
    t.index ["eefps_qrcf_id", "question_row_columns_question_row_column_option_id", "active"], name: "index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_active"
    t.index ["eefps_qrcf_id", "question_row_columns_question_row_column_option_id", "deleted_at"], name: "index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_deleted_at"
    t.index ["eefps_qrcf_id"], name: "index_eefpsqrcfqrcqrco_on_eefps_qrcf_id"
    t.index ["question_row_columns_question_row_column_option_id"], name: "index_eefpsqrcfqrcqrco_on_qrcqrco_id"
  end

  create_table "ef_instructions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "ef_id"
    t.string "section"
    t.string "data_element"
    t.text "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ef_section_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "extraction_form_id", null: false
    t.string "section"
    t.boolean "by_arm", default: false
    t.boolean "by_outcome", default: false
    t.boolean "include_total", default: false
    t.boolean "by_diagnostic_test", default: false
  end

  create_table "eft_adverse_event_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "extraction_form_template_id"
  end

  create_table "eft_arm_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "eft_arm_detail_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_arm_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.text "question", limit: 16777215
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.text "instruction", limit: 16777215
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_arms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.string "name"
    t.string "description"
    t.string "note"
  end

  create_table "eft_baseline_characteristic_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "eft_baseline_characteristic_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number", default: 0
    t.integer "column_number", default: 0
  end

  create_table "eft_baseline_characteristics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.text "question"
    t.string "field_type"
    t.string "field_notes"
    t.integer "question_number"
    t.text "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_design_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "eft_design_detail_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number", default: 0
    t.integer "column_number", default: 0
  end

  create_table "eft_design_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.text "question"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.text "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_diagnostic_test_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "eft_diagnostic_test_detail_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_diagnostic_test_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.text "question"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.text "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_diagnostic_tests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.integer "test_type"
    t.string "title"
    t.text "description"
    t.text "notes"
  end

  create_table "eft_matrix_dropdown_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "row_id"
    t.integer "column_id"
    t.string "option_text"
    t.integer "option_number"
    t.string "model_name"
  end

  create_table "eft_outcome_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "eft_outcome_detail_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_outcome_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.text "question", limit: 16777215
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.text "instruction", limit: 16777215
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_outcome_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "note"
    t.integer "extraction_form_template_id"
    t.string "outcome_type"
  end

  create_table "eft_quality_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "eft_quality_detail_id"
    t.string "option_text"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_quality_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "extraction_form_id"
    t.text "question"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.text "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_quality_dimension_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "field_notes"
    t.integer "extraction_form_template_id"
  end

  create_table "eft_quality_rating_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.string "rating_item"
    t.integer "display_number"
  end

  create_table "eft_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_template_id"
    t.string "section_name"
    t.boolean "included"
  end

  create_table "export_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_export_types_on_name", unique: true
  end

  create_table "exported_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.integer "file_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_type_id"], name: "index_exported_files_on_file_type_id"
    t.index ["project_id"], name: "index_exported_files_on_project_id"
    t.index ["user_id"], name: "index_exported_files_on_user_id"
  end

  create_table "exported_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "projects_user_id"
    t.bigint "export_type_id"
    t.text "external_url"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["export_type_id"], name: "index_exported_items_on_export_type_id"
    t.index ["projects_user_id"], name: "index_exported_items_on_projects_user_id"
  end

  create_table "extraction_checksums", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "extraction_id"
    t.string "hexdigest"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_stale"
    t.index ["deleted_at"], name: "index_extraction_checksums_on_deleted_at"
    t.index ["extraction_id"], name: "index_extraction_checksums_on_extraction_id"
  end

  create_table "extraction_form_adverse_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "note"
    t.integer "extraction_form_id"
  end

  create_table "extraction_form_arms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "note"
    t.integer "extraction_form_id"
    t.index ["extraction_form_id"], name: "extractionformarm_extractionform_idx"
  end

  create_table "extraction_form_diagnostic_tests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "test_type"
    t.string "title"
    t.text "description"
    t.text "notes"
    t.integer "extraction_form_id"
    t.index ["extraction_form_id"], name: "extractionformdiagnostic_extractionform_idx"
  end

  create_table "extraction_form_key_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_id"
    t.integer "key_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id"], name: "EDIT_TAB"
    t.index ["extraction_form_id"], name: "extractionformkeyquestion_extractionform_idx"
  end

  create_table "extraction_form_outcome_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "note"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "outcome_type"
    t.index ["extraction_form_id"], name: "extractionformoutcome_extractionform_idx"
  end

  create_table "extraction_form_section_copies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "section_name"
    t.integer "copied_from"
    t.integer "copied_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_name", "copied_from"], name: "EDIT_TAB"
  end

  create_table "extraction_form_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_id"
    t.string "section_name"
    t.boolean "included"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "borrowed_from_efid"
    t.index ["extraction_form_id", "section_name"], name: "EDIT_TAB"
    t.index ["extraction_form_id"], name: "extractionformsection_extractionform_idx"
  end

  create_table "extraction_form_templates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.integer "creator_id"
    t.text "notes"
    t.boolean "adverse_event_display_arms"
    t.boolean "adverse_event_display_total"
    t.boolean "show_to_local"
    t.boolean "show_to_world"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.integer "template_form_id"
  end

  create_table "extraction_forms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_on_deleted_at"
    t.index ["name"], name: "index_extraction_forms_on_name", unique: true
  end

  create_table "extraction_forms_project_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_project_types_on_deleted_at"
    t.index ["name"], name: "index_extraction_forms_project_types_on_name", unique: true
  end

  create_table "extraction_forms_projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_project_type_id"
    t.integer "extraction_form_id"
    t.integer "project_id"
    t.boolean "public", default: false
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_extraction_forms_projects_on_active"
    t.index ["deleted_at"], name: "index_extraction_forms_projects_on_deleted_at"
    t.index ["extraction_form_id", "project_id", "active"], name: "index_efp_on_ef_id_p_id_active"
    t.index ["extraction_form_id", "project_id", "deleted_at"], name: "index_efp_on_ef_id_p_id_deleted_at"
    t.index ["extraction_form_id"], name: "index_efp_on_ef_id"
    t.index ["extraction_forms_project_type_id", "extraction_form_id", "project_id", "active"], name: "index_efp_on_efpt_id_ef_id_p_id_active"
    t.index ["extraction_forms_project_type_id", "extraction_form_id", "project_id", "deleted_at"], name: "index_efp_on_efpt_id_ef_id_p_id_deleted_at"
    t.index ["extraction_forms_project_type_id"], name: "index_efp_on_efpt_id"
    t.index ["project_id"], name: "index_efp_on_p_id"
  end

  create_table "extraction_forms_projects_section_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_projects_section_id"
    t.boolean "by_type1"
    t.boolean "include_total"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_efpso_on_deleted_at"
    t.index ["extraction_forms_projects_section_id", "deleted_at"], name: "index_efpso_on_efps_id_deleted_at"
    t.index ["extraction_forms_projects_section_id"], name: "index_efpso_on_efps_id"
  end

  create_table "extraction_forms_projects_section_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_extraction_forms_projects_section_types_on_deleted_at"
    t.index ["name"], name: "index_extraction_forms_projects_section_types_on_name", unique: true
  end

  create_table "extraction_forms_projects_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_project_id"
    t.integer "extraction_forms_projects_section_type_id"
    t.integer "section_id"
    t.integer "extraction_forms_projects_section_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.index ["active"], name: "index_extraction_forms_projects_sections_on_active"
    t.index ["deleted_at"], name: "index_extraction_forms_projects_sections_on_deleted_at"
    t.index ["extraction_forms_project_id", "extraction_forms_projects_section_type_id", "section_id", "extraction_forms_projects_section_id", "active"], name: "index_efps_on_efp_id_efpst_id_s_id_efps_id_active"
    t.index ["extraction_forms_project_id", "extraction_forms_projects_section_type_id", "section_id", "extraction_forms_projects_section_id", "deleted_at"], name: "index_efps_on_efp_id_efpst_id_s_id_efps_id_deleted_at"
    t.index ["extraction_forms_project_id"], name: "index_efps_on_efp_id"
    t.index ["extraction_forms_projects_section_id"], name: "index_efps_on_efps_id"
    t.index ["extraction_forms_projects_section_type_id"], name: "index_efps_on_efpst_id"
    t.index ["section_id"], name: "index_efps_on_s_id"
  end

  create_table "extraction_forms_projects_sections_type1_rows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "extraction_forms_projects_sections_type1_id"
    t.bigint "population_name_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["extraction_forms_projects_sections_type1_id"], name: "index_efpst1r_on_efpst1_id"
    t.index ["population_name_id"], name: "index_efpst1r_on_pn_id"
  end

  create_table "extraction_forms_projects_sections_type1s", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_projects_section_id"
    t.integer "type1_id"
    t.integer "type1_type_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_extraction_forms_projects_sections_type1s_on_active"
    t.index ["deleted_at"], name: "index_extraction_forms_projects_sections_type1s_on_deleted_at"
    t.index ["extraction_forms_projects_section_id", "type1_id", "type1_type_id", "active"], name: "index_efpst1_on_efps_id_t1_id_t1_type_id_active_uniq", unique: true
    t.index ["extraction_forms_projects_section_id", "type1_id", "type1_type_id", "deleted_at"], name: "index_efpst1_on_efps_id_t1_id_t1_type_id_deleted_at_uniq", unique: true
    t.index ["extraction_forms_projects_section_id"], name: "index_efpst1_on_efps_id"
    t.index ["type1_id"], name: "index_efpst1_on_t1_id"
    t.index ["type1_type_id"], name: "index_efpst1_on_t1_type_id"
  end

  create_table "extraction_forms_projects_sections_type1s_timepoint_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_projects_sections_type1_id"
    t.integer "timepoint_name_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_efpst1tn_on_active"
    t.index ["deleted_at"], name: "index_efpst1tn_on_deleted_at"
    t.index ["extraction_forms_projects_sections_type1_id", "timepoint_name_id", "active"], name: "index_efpst1tn_on_efpst1_id_tn_id_active"
    t.index ["extraction_forms_projects_sections_type1_id", "timepoint_name_id", "deleted_at"], name: "index_efpst1tn_on_efpst1_id_tn_id_deleted_at"
    t.index ["extraction_forms_projects_sections_type1_id"], name: "index_efpst1tn_on_efpst1_id"
    t.index ["timepoint_name_id"], name: "index_efpst1tn_on_tn_id"
  end

  create_table "extractions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "citations_project_id"
    t.integer "projects_users_role_id"
    t.boolean "consolidated", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["citations_project_id"], name: "index_extractions_on_citations_project_id"
    t.index ["deleted_at"], name: "index_extractions_on_deleted_at"
    t.index ["project_id", "citations_project_id", "projects_users_role_id", "deleted_at"], name: "index_e_on_p_id_cp_id_pur_id_deleted_at_uniq", unique: true
    t.index ["project_id"], name: "index_extractions_on_project_id"
    t.index ["projects_users_role_id"], name: "index_extractions_on_projects_users_role_id"
  end

  create_table "extractions_extraction_forms_projects_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_id"
    t.integer "extraction_forms_projects_section_id"
    t.integer "extractions_extraction_forms_projects_section_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_eefps_on_active"
    t.index ["deleted_at"], name: "index_eefps_on_deleted_at"
    t.index ["extraction_forms_projects_section_id"], name: "index_eefps_on_efps_id"
    t.index ["extraction_id", "extraction_forms_projects_section_id", "extractions_extraction_forms_projects_section_id", "active"], name: "index_eefps_on_e_id_efps_id_eefps_id_active"
    t.index ["extraction_id", "extraction_forms_projects_section_id", "extractions_extraction_forms_projects_section_id", "deleted_at"], name: "index_eefps_on_e_id_efps_id_eefps_id_deleted_at"
    t.index ["extraction_id"], name: "index_eefps_on_e_id"
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefps_on_eefps_id"
  end

  create_table "extractions_extraction_forms_projects_sections_followup_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "extractions_extraction_forms_projects_section_id"
    t.bigint "followup_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "active"
    t.bigint "extractions_extraction_forms_projects_sections_type1_id"
    t.index ["deleted_at"], name: "index_eefpsff_followup_fields_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_section_id", "extractions_extraction_forms_projects_sections_type1_id", "followup_field_id", "active"], name: "index_eefpsff_on_eefps_eefpst1_ff_id", unique: true
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefpsff_followup_fields_on_extraction_id"
    t.index ["followup_field_id"], name: "index_eefpsff_on_followup_field_id"
  end

  create_table "extractions_extraction_forms_projects_sections_type1_row_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extractions_extraction_forms_projects_sections_type1_row_id"
    t.integer "timepoint_name_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_eefpst1rc_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_row_id", "timepoint_name_id", "deleted_at"], name: "index_eefpst1rc_on_eefpst1r_id_tn_id_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_row_id"], name: "index_eefpst1rc_on_eefpst1r_id"
    t.index ["timepoint_name_id"], name: "index_eefpst1rc_on_tn_id"
  end

  create_table "extractions_extraction_forms_projects_sections_type1_rows", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extractions_extraction_forms_projects_sections_type1_id"
    t.integer "population_name_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_eefpst1r_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_id", "population_name_id", "deleted_at"], name: "index_eefpst1r_on_eefpst1_id_pn_id_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_id"], name: "index_eefpst1r_on_eefpst1_id"
    t.index ["population_name_id"], name: "index_eefpst1r_on_pn_id"
  end

  create_table "extractions_extraction_forms_projects_sections_type1s", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "type1_type_id"
    t.integer "extractions_extraction_forms_projects_section_id"
    t.integer "type1_id"
    t.string "units"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_eefpst1_on_active"
    t.index ["deleted_at"], name: "index_eefpst1_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_section_id"], name: "index_eefpst1_on_eefps_id"
    t.index ["type1_id"], name: "index_eefpst1_on_t1_id"
    t.index ["type1_type_id", "extractions_extraction_forms_projects_section_id", "type1_id", "active"], name: "index_eefpst1_on_t1t_id_eefps_id_t1_id_active", unique: true
    t.index ["type1_type_id", "extractions_extraction_forms_projects_section_id", "type1_id", "deleted_at"], name: "index_eefpst1_on_t1t_id_eefps_id_t1_id_deleted_at", unique: true
    t.index ["type1_type_id"], name: "index_eefpst1_on_t1t_id"
  end

  create_table "extractions_key_questions_projects_selections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "extraction_id"
    t.bigint "key_questions_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["extraction_id"], name: "index_ekqps_on_extractions_id"
    t.index ["key_questions_project_id"], name: "index_ekqps_on_key_questions_projects_id"
  end

  create_table "extractions_projects_users_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_id"
    t.integer "projects_users_role_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_epur_on_active"
    t.index ["deleted_at"], name: "index_epur_on_deleted_at"
    t.index ["extraction_id", "projects_users_role_id", "active"], name: "index_epur_on_e_id_pur_id_active_uniq", unique: true
    t.index ["extraction_id", "projects_users_role_id", "deleted_at"], name: "index_epur_on_e_id_pur_id_deleted_at_uniq", unique: true
    t.index ["extraction_id"], name: "index_epur_on_e_id"
    t.index ["projects_users_role_id"], name: "index_epur_on_pur_id"
  end

  create_table "feedback_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "url"
    t.string "page"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_file_types_on_name", unique: true
  end

  create_table "followup_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "question_row_columns_question_row_column_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_followup_fields_on_deleted_at"
    t.index ["question_row_columns_question_row_column_option_id"], name: "index_followup_fields_on_qrcqrco_id"
  end

  create_table "footnote_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "footnote_number"
    t.string "field_name"
    t.string "page_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "footnotes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "note_number"
    t.integer "study_id"
    t.string "page_name"
    t.string "data_type"
    t.string "note_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frequencies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_frequencies_on_deleted_at"
  end

  create_table "funding_sources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "funding_sources_sd_meta_data", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "funding_source_id"
    t.integer "sd_meta_datum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funding_source_id"], name: "index_funding_sources_sd_meta_data_on_funding_source_id"
    t.index ["sd_meta_datum_id"], name: "index_funding_sources_sd_meta_data_on_sd_meta_datum_id"
  end

  create_table "import_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_import_types_on_name", unique: true
  end

  create_table "imported_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "file_type_id"
    t.integer "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "key_question_id"
    t.integer "import_id"
    t.index ["file_type_id"], name: "index_imported_files_on_file_type_id"
    t.index ["key_question_id"], name: "index_imported_files_on_key_question_id"
    t.index ["section_id"], name: "index_imported_files_on_section_id"
  end

  create_table "imports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "import_type_id"
    t.integer "projects_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "role_id"
    t.string "invitable_type"
    t.bigint "invitable_id"
    t.boolean "enabled", default: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitable_type", "invitable_id"], name: "index_invitations_on_invitable_type_and_invitable_id"
    t.index ["role_id"], name: "index_invitations_on_role_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "journals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "citation_id"
    t.integer "volume"
    t.integer "issue"
    t.string "name", limit: 1000, collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "publication_date", collation: "utf8_general_ci"
    t.index ["citation_id"], name: "index_journals_on_citation_id"
  end

  create_table "key_question_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "key_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "name", collation: "utf8_bin"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_key_questions_on_deleted_at"
    t.index ["name"], name: "index_key_questions_on_name", unique: true, length: 255
  end

  create_table "key_questions_projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_projects_section_id"
    t.integer "key_question_id"
    t.integer "project_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_key_questions_projects_on_active"
    t.index ["deleted_at"], name: "index_key_questions_projects_on_deleted_at"
    t.index ["extraction_forms_projects_section_id", "key_question_id", "project_id", "active"], name: "index_kqp_on_efps_id_kq_id_p_id_active"
    t.index ["extraction_forms_projects_section_id", "key_question_id", "project_id", "deleted_at"], name: "index_kqp_on_efps_id_kq_id_p_id_deleted_at"
    t.index ["extraction_forms_projects_section_id"], name: "index_kqp_on_efps_id"
    t.index ["key_question_id", "project_id", "active"], name: "index_kqp_on_kq_id_p_id_active"
    t.index ["key_question_id", "project_id", "deleted_at"], name: "index_kqp_on_kq_id_p_id_deleted_at"
    t.index ["key_question_id"], name: "index_kqp_on_kq_id"
    t.index ["project_id"], name: "index_kqp_on_p_id"
  end

  create_table "key_questions_projects_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "key_questions_project_id"
    t.integer "question_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_questions_project_id", "question_id", "active"], name: "index_kqpq_on_kqp_id_q_id_active_uniq", unique: true
    t.index ["key_questions_project_id", "question_id", "deleted_at"], name: "index_kqpq_on_kqp_id_q_id_deleted_at_uniq", unique: true
    t.index ["key_questions_project_id"], name: "index_kqpq_on_kqp_id"
    t.index ["question_id"], name: "index_kqpq_on_q_id"
  end

  create_table "keywords", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 5000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_keywords_on_deleted_at"
  end

  create_table "label_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "labels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citations_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "projects_users_role_id"
    t.datetime "deleted_at"
    t.integer "label_type_id"
    t.index ["citations_project_id"], name: "index_labels_on_citations_project_id"
    t.index ["deleted_at"], name: "index_labels_on_deleted_at"
    t.index ["label_type_id"], name: "index_labels_on_label_type_id"
    t.index ["projects_users_role_id"], name: "index_labels_on_projects_users_role_id"
  end

  create_table "labels_reasons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "label_id"
    t.integer "reason_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "projects_users_role_id"
    t.index ["deleted_at"], name: "index_labels_reasons_on_deleted_at"
    t.index ["label_id"], name: "index_labels_reasons_on_label_id"
    t.index ["projects_users_role_id"], name: "index_labels_reasons_on_projects_users_role_id"
    t.index ["reason_id"], name: "index_labels_reasons_on_reason_id"
  end

  create_table "matrix_dropdown_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "row_id"
    t.integer "column_id"
    t.string "option_text"
    t.integer "option_number"
    t.string "model_name"
    t.index ["column_id", "model_name"], name: "mdo_cix"
    t.index ["column_id"], name: "matrixdropdown_column_idx"
    t.index ["row_id"], name: "matrixdropdown_row_idx"
  end

  create_table "measurements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.integer "comparisons_measure_id"
    t.index ["comparisons_measure_id"], name: "index_measurements_on_comparisons_measure_id"
  end

  create_table "measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_measures_on_deleted_at"
  end

  create_table "message_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "frequency_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_message_types_on_deleted_at"
    t.index ["frequency_id"], name: "index_message_types_on_frequency_id"
  end

  create_table "messages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "message_type_id"
    t.string "name"
    t.text "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_messages_on_deleted_at"
    t.index ["message_type_id"], name: "index_messages_on_message_type_id"
  end

  create_table "notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "notable_type"
    t.integer "notable_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "projects_users_role_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_notes_on_deleted_at"
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id"
    t.index ["projects_users_role_id"], name: "index_notes_on_projects_users_role_id"
  end

  create_table "notifiers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "fk_rails_b4b53e07b8"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "fk_rails_732cb83ab7"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "orderings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "orderable_type"
    t.integer "orderable_id"
    t.integer "position"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_orderings_on_active"
    t.index ["deleted_at"], name: "index_orderings_on_deleted_at"
    t.index ["orderable_type", "orderable_id", "active"], name: "index_orderings_on_type_id_active_uniq", unique: true
    t.index ["orderable_type", "orderable_id", "deleted_at"], name: "index_orderings_on_type_id_deleted_at_uniq", unique: true
    t.index ["orderable_type", "orderable_id"], name: "index_orderings_on_orderable_type_and_orderable_id"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "outcome_column_values", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "timepoint_id"
    t.integer "subgroup_id"
    t.string "value"
    t.boolean "is_calculated"
    t.integer "arm_id"
    t.integer "column_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "column_header"
    t.string "outcome_type"
    t.string "column_name"
    t.string "column_description"
    t.integer "extraction_form_id"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparison_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "column_header"
    t.string "outcome_type"
    t.string "column_name"
    t.string "column_description"
    t.integer "extraction_form_id"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparison_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "arm_id"
    t.integer "outcome_id"
    t.integer "timepoint_id"
    t.integer "outcome_comparison_column_id"
    t.boolean "is_calculated"
    t.string "value"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparisons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "arm_id"
    t.integer "outcome_id"
    t.integer "timepoint_id"
    t.integer "outcome_comparison_column_id"
    t.boolean "is_calculated"
    t.string "value"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_data_entries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "extraction_form_id"
    t.integer "timepoint_id"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "display_number", default: 1
    t.integer "subgroup_id", default: 0
    t.index ["extraction_form_id", "outcome_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id", "study_id", "outcome_id", "subgroup_id", "timepoint_id"], name: "ReportBuilder0"
    t.index ["extraction_form_id", "study_id", "outcome_id", "subgroup_id"], name: "StudyDataCache"
    t.index ["extraction_form_id"], name: "outcomedataentry_extractionform_idx"
    t.index ["outcome_id", "subgroup_id"], name: "EDIT_TAB"
    t.index ["outcome_id"], name: "outcomedataentry_outcome_idx"
    t.index ["study_id"], name: "outcomedataentry_study_idx"
    t.index ["subgroup_id"], name: "outcomedataentry_subgroup_idx"
    t.index ["timepoint_id"], name: "outcomedataentry_timepoint_idx"
  end

  create_table "outcome_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_measure_id"
    t.text "value"
    t.string "footnote"
    t.boolean "is_calculated", default: false
    t.integer "arm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "footnote_number", default: 0
    t.index ["arm_id", "outcome_measure_id"], name: "ReportBuilder0"
    t.index ["arm_id"], name: "outcomedatapoint_arm_idx"
    t.index ["outcome_measure_id"], name: "StudyData"
    t.index ["outcome_measure_id"], name: "outcomedatapoint_outcomemeasurue_idx"
  end

  create_table "outcome_detail_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_detail_field_id"
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "arm_id", default: 0
    t.integer "outcome_id", default: 0
    t.index ["extraction_form_id", "study_id", "outcome_detail_field_id", "row_field_id", "column_field_id"], name: "StudyDataRowCol"
    t.index ["extraction_form_id", "study_id", "outcome_detail_field_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "outcomedetaildatapoint_extractionform_idx"
    t.index ["outcome_detail_field_id", "study_id"], name: "oddp_odix"
    t.index ["outcome_detail_field_id"], name: "outcomedetaildatapoint_outcomedetailfield_idx"
    t.index ["study_id"], name: "outcomedetaildatapoint_study_idx"
  end

  create_table "outcome_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_detail_id"
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.index ["outcome_detail_id", "column_number", "row_number"], name: "StudyDataColRow"
    t.index ["outcome_detail_id", "column_number"], name: "StudyDataCol"
    t.index ["outcome_detail_id", "row_number"], name: "odf_odix"
    t.index ["outcome_detail_id"], name: "outcomedetailfield_outcomedetail_idx"
  end

  create_table "outcome_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "question"
    t.integer "extraction_form_id"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
    t.index ["extraction_form_id", "question_number"], name: "od_efix"
    t.index ["extraction_form_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "outcomedetail_extractionform_idx"
  end

  create_table "outcome_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_data_entry_id"
    t.string "title"
    t.text "description"
    t.string "unit"
    t.string "note"
    t.integer "measure_type", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["outcome_data_entry_id"], name: "StudyData"
    t.index ["outcome_data_entry_id"], name: "outcomemeasure_outcomedataentry_idx"
  end

  create_table "outcome_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "arm_id"
    t.integer "outcome_id"
    t.integer "timepoint_id"
    t.integer "outcome_column_id"
    t.boolean "is_calculated"
    t.string "value"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["outcome_id", "extraction_form_id", "arm_id", "timepoint_id"], name: "StudyDataArmTP"
    t.index ["outcome_id", "extraction_form_id"], name: "StudyData"
  end

  create_table "outcome_results_notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "timepoint_id"
    t.integer "subgroup_id"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_subgroups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["outcome_id"], name: " outcomesubgroup_outcome_idx"
    t.index ["outcome_id"], name: "EDIT_TAB"
  end

  create_table "outcome_timepoint_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "study_id"
    t.integer "arm_id"
    t.integer "timepoint_id"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_calculated"
  end

  create_table "outcome_timepoints", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "outcome_id"
    t.string "number"
    t.string "time_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["outcome_id"], name: "EDIT_TAB"
    t.index ["outcome_id"], name: "outcometimepoint_outcome_idx"
  end

  create_table "outcomes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.string "title"
    t.boolean "is_primary"
    t.string "units"
    t.text "description"
    t.text "notes"
    t.string "outcome_type"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "outcome_extractionform_idx"
    t.index ["study_id", "outcome_type", "extraction_form_id"], name: "EDIT_TAB"
    t.index ["study_id"], name: "outcome_study_idx"
  end

  create_table "pending_invitations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "invitation_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_id"], name: "index_pending_invitations_on_invitation_id"
    t.index ["user_id"], name: "index_pending_invitations_on_user_id"
  end

  create_table "population_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_population_names_on_deleted_at"
  end

  create_table "predictions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citations_project_id"
    t.integer "value"
    t.integer "num_yes_votes"
    t.float "predicted_probability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["citations_project_id"], name: "index_predictions_on_citations_project_id"
  end

  create_table "primary_publication_numbers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "primary_publication_id"
    t.string "number"
    t.string "number_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["primary_publication_id"], name: "primarypublicationnumber_primarypublication_idx"
  end

  create_table "primary_publications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.text "title"
    t.text "author"
    t.text "country"
    t.string "year"
    t.string "pmid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "journal"
    t.string "volume"
    t.string "issue"
    t.string "trial_title"
    t.text "abstract"
    t.index ["study_id"], name: "StudyData"
    t.index ["study_id"], name: "primarypublication_study_idx"
  end

  create_table "priorities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "citations_project_id"
    t.integer "value"
    t.integer "num_times_labeled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["citations_project_id"], name: "index_priorities_on_citations_project_id"
  end

  create_table "profiles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.string "time_zone", default: "UTC"
    t.string "username"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.boolean "advanced_mode", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_profiles_on_deleted_at"
    t.index ["organization_id"], name: "index_profiles_on_organization_id"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
    t.index ["username"], name: "index_profiles_on_username", unique: true
  end

  create_table "project_copy_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.integer "clone_id"
    t.boolean "include_forms"
    t.boolean "include_studies"
    t.boolean "include_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_project_copy_requests_on_user_id"
  end

  create_table "projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "attribution"
    t.text "methodology_description"
    t.string "prospero"
    t.string "doi"
    t.text "notes"
    t.string "funding_source"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "authors_of_report"
    t.index ["deleted_at"], name: "index_projects_on_deleted_at"
  end

  create_table "projects_studies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "study_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_ps_on_active"
    t.index ["deleted_at"], name: "index_ps_on_deleted_at"
    t.index ["project_id", "study_id", "active"], name: "index_ps_on_p_id_s_id_active"
    t.index ["project_id", "study_id", "deleted_at"], name: "index_ps_on_p_id_s_id_deleted_at"
    t.index ["project_id"], name: "index_projects_studies_on_project_id"
    t.index ["study_id"], name: "index_projects_studies_on_study_id"
  end

  create_table "projects_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_projects_users_on_active"
    t.index ["deleted_at"], name: "index_projects_users_on_deleted_at"
    t.index ["project_id", "user_id", "active"], name: "index_pu_on_p_id_u_id_active_uniq", unique: true
    t.index ["project_id", "user_id", "deleted_at"], name: "index_pu_on_p_id_u_id_deleted_at_uniq", unique: true
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "projects_users_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "projects_user_id"
    t.integer "role_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_projects_users_roles_on_active"
    t.index ["deleted_at"], name: "index_projects_users_roles_on_deleted_at"
    t.index ["projects_user_id", "role_id", "active"], name: "index_pur_on_pu_id_r_id_active_uniq", unique: true
    t.index ["projects_user_id", "role_id", "deleted_at"], name: "index_pur_on_pu_id_r_id_deleted_at_uniq", unique: true
    t.index ["projects_user_id"], name: "index_projects_users_roles_on_projects_user_id"
    t.index ["role_id"], name: "index_projects_users_roles_on_role_id"
  end

  create_table "projects_users_roles_teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "projects_users_role_id"
    t.integer "team_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_projects_users_roles_teams_on_active"
    t.index ["deleted_at"], name: "index_projects_users_roles_teams_on_deleted_at"
    t.index ["projects_users_role_id"], name: "index_projects_users_roles_teams_on_projects_users_role_id"
    t.index ["team_id"], name: "index_projects_users_roles_teams_on_team_id"
  end

  create_table "projects_users_term_groups_colors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "term_groups_color_id"
    t.integer "projects_user_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_projects_users_term_groups_colors_on_deleted_at"
    t.index ["projects_user_id"], name: "index_projects_users_term_groups_colors_on_projects_user_id"
    t.index ["term_groups_color_id"], name: "index_projects_users_term_groups_colors_on_term_groups_color_id"
  end

  create_table "projects_users_term_groups_colors_terms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "projects_users_term_groups_color_id"
    t.integer "term_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_projects_users_term_groups_colors_terms_on_deleted_at"
    t.index ["projects_users_term_groups_color_id"], name: "index_putgcp_on_putc_id"
    t.index ["term_id"], name: "index_putgcp_on_terms_id"
  end

  create_table "publishings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "publishable_type"
    t.integer "publishable_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_publishings_on_active"
    t.index ["deleted_at"], name: "index_publishings_on_deleted_at"
    t.index ["publishable_type", "publishable_id", "user_id", "active"], name: "index_publishings_on_type_id_user_id_active_uniq", unique: true
    t.index ["publishable_type", "publishable_id", "user_id", "deleted_at"], name: "index_publishings_on_type_id_user_id_deleted_at_uniq", unique: true
    t.index ["publishable_type", "publishable_id"], name: "index_publishings_on_publishable_type_and_publishable_id"
    t.index ["user_id"], name: "index_publishings_on_user_id"
  end

  create_table "quality_detail_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "quality_detail_field_id"
    t.text "value"
    t.text "notes"
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "subquestion_value"
    t.integer "row_field_id", default: 0
    t.integer "column_field_id", default: 0
    t.integer "arm_id", default: 0
    t.integer "outcome_id", default: 0
    t.index ["quality_detail_field_id", "study_id"], name: "qddp_odix"
  end

  create_table "quality_detail_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "quality_detail_id"
    t.string "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subquestion"
    t.boolean "has_subquestion"
    t.integer "column_number", default: 0
    t.integer "row_number", default: 0
    t.index ["quality_detail_id", "row_number"], name: "qdf_odix"
  end

  create_table "quality_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "question"
    t.integer "extraction_form_id"
    t.string "field_type"
    t.string "field_note"
    t.integer "question_number"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "instruction"
    t.boolean "is_matrix", default: false
    t.boolean "include_other_as_option"
    t.index ["extraction_form_id", "question_number"], name: "qd_efix"
  end

  create_table "quality_dimension_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "quality_dimension_field_id"
    t.string "value"
    t.text "notes"
    t.integer "study_id"
    t.string "field_type"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id", "quality_dimension_field_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id", "study_id", "quality_dimension_field_id"], name: "StudyDataCache"
    t.index ["quality_dimension_field_id"], name: "qualitydimensiondatapoint_qualitydimensionfield_idx"
  end

  create_table "quality_dimension_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "title"
    t.text "field_notes"
    t.integer "extraction_form_id"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "question_number"
    t.index ["extraction_form_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "qualitydimensionfield_extractionform_idx"
  end

  create_table "quality_dimension_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_quality_dimension_options_on_deleted_at"
  end

  create_table "quality_dimension_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quality_dimension_section_id"
    t.string "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_quality_dimension_questions_on_deleted_at"
    t.index ["quality_dimension_section_id"], name: "index_qdq_on_qds_id"
  end

  create_table "quality_dimension_questions_quality_dimension_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quality_dimension_question_id"
    t.integer "quality_dimension_option_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quality_dimension_option_id"], name: "index_qdqqdo_on_qdo_id"
    t.index ["quality_dimension_question_id", "quality_dimension_option_id", "active"], name: "index_qdq_id_qdo_id_active_uniq", unique: true
    t.index ["quality_dimension_question_id"], name: "index_qdqqdo_on_qdq_id"
  end

  create_table "quality_dimension_section_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quality_dimension_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "quality_dimension_section_group_id"
    t.index ["deleted_at"], name: "index_quality_dimension_sections_on_deleted_at"
    t.index ["quality_dimension_section_group_id"], name: "index_qds_on_qdsg_id"
  end

  create_table "quality_rating_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.string "guideline_used"
    t.string "current_overall_rating"
    t.text "notes"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id", "study_id"], name: "StudyData"
    t.index ["extraction_form_id"], name: "qualityratingdatapoint_extractionform_idx"
    t.index ["study_id"], name: "qualityratingdatapoint_study_idx"
  end

  create_table "quality_rating_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "extraction_form_id"
    t.string "rating_item"
    t.integer "display_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id"], name: "qualityratingfield_extractionform_idx"
  end

  create_table "quality_ratings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.string "guideline_used"
    t.string "current_overall_rating"
    t.text "notes"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["extraction_form_id", "study_id"], name: "StudyData"
  end

  create_table "question_row_column_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "question_row_column_id"
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_row_column_fields_on_deleted_at"
    t.index ["question_row_column_id", "deleted_at"], name: "index_qrcf_on_qrc_id_deleted_at"
    t.index ["question_row_column_id"], name: "index_qrcf_on_qrc_id"
  end

  create_table "question_row_column_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "field_type"
    t.string "label"
    t.index ["deleted_at"], name: "index_question_row_column_options_on_deleted_at"
  end

  create_table "question_row_column_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_row_column_types_on_deleted_at"
  end

  create_table "question_row_columns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "question_row_id"
    t.integer "question_row_column_type_id"
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_row_columns_on_deleted_at"
    t.index ["question_row_column_type_id"], name: "index_qrc_on_qrct_id"
    t.index ["question_row_id", "deleted_at"], name: "index_qrc_on_qr_id_deleted_at"
    t.index ["question_row_id", "question_row_column_type_id", "deleted_at"], name: "index_qrc_on_qr_id_qrct_id_deleted_at"
    t.index ["question_row_id"], name: "index_question_row_columns_on_question_row_id"
  end

  create_table "question_row_columns_question_row_column_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "question_row_column_id"
    t.integer "question_row_column_option_id"
    t.text "name"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_qrcqrco_on_active"
    t.index ["deleted_at"], name: "index_qrcqrco_on_deleted_at"
    t.index ["question_row_column_id", "question_row_column_option_id", "active"], name: "index_qrcqrco_on_qrc_id_qrco_id_active"
    t.index ["question_row_column_id", "question_row_column_option_id", "deleted_at"], name: "index_qrcqrco_on_qrc_id_qrco_id_deleted_at"
    t.index ["question_row_column_id"], name: "index_qrcqrco_on_qrc_id"
    t.index ["question_row_column_option_id"], name: "index_qrcqrco_on_qrco_id"
  end

  create_table "question_rows", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "question_id"
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_question_rows_on_deleted_at"
    t.index ["question_id", "deleted_at"], name: "index_qr_on_q_id_deleted_at"
    t.index ["question_id"], name: "index_question_rows_on_question_id"
  end

  create_table "questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "extraction_forms_projects_section_id"
    t.text "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
    t.index ["extraction_forms_projects_section_id", "deleted_at"], name: "index_q_on_efps_id_deleted_at"
    t.index ["extraction_forms_projects_section_id"], name: "index_questions_on_extraction_forms_projects_section_id"
  end

  create_table "reasons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "label_type_id"
    t.index ["deleted_at"], name: "index_reasons_on_deleted_at"
    t.index ["label_type_id"], name: "index_reasons_on_label_type_id"
  end

  create_table "records", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.string "recordable_type"
    t.integer "recordable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_records_on_deleted_at"
    t.index ["recordable_type", "recordable_id"], name: "index_records_on_recordable_type_and_recordable_id"
  end

  create_table "registars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "fname"
    t.string "lname"
    t.string "organization"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "validationcode"
  end

  create_table "registry", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "crs_id", null: false
    t.integer "former_id"
    t.string "form", null: false, collation: "utf8_unicode_ci"
    t.string "name", null: false, collation: "utf8_unicode_ci"
    t.text "authors", collation: "utf8_unicode_ci"
    t.text "title", collation: "utf8_unicode_ci"
    t.text "original_title", collation: "utf8_unicode_ci"
    t.text "journal", collation: "utf8_unicode_ci"
    t.string "year", collation: "utf8_unicode_ci"
    t.string "volume", collation: "utf8_unicode_ci"
    t.string "issue", collation: "utf8_unicode_ci"
    t.string "pages", collation: "utf8_unicode_ci"
    t.string "edition", collation: "utf8_unicode_ci"
    t.string "editors", collation: "utf8_unicode_ci"
    t.string "publisher", collation: "utf8_unicode_ci"
    t.string "country", collation: "utf8_unicode_ci"
    t.string "study_design", collation: "utf8_unicode_ci"
    t.text "abstract", limit: 4294967295, collation: "utf8_unicode_ci"
    t.string "pubmed", collation: "utf8_unicode_ci"
    t.string "embase", collation: "utf8_unicode_ci"
    t.string "other_ids", collation: "utf8_unicode_ci"
    t.string "doi", collation: "utf8_unicode_ci"
    t.string "isbn", collation: "utf8_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registry_data_points", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false, collation: "utf8_unicode_ci"
    t.string "registry_name", null: false, collation: "utf8_unicode_ci"
    t.integer "registry_fk", null: false
    t.text "value", collation: "utf8_unicode_ci"
    t.string "subvalue", collation: "utf8_unicode_ci"
    t.text "notes", collation: "utf8_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registry_fields", id: :string, collation: "utf8_unicode_ci", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title", null: false, collation: "utf8_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registry_usages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "requestor_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "login"
    t.integer "project_id"
  end

  create_table "result_statistic_section_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_result_statistic_section_types_on_deleted_at"
  end

  create_table "result_statistic_section_types_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "result_statistic_section_type_id"
    t.integer "measure_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.integer "type1_type_id"
    t.integer "result_statistic_section_types_measure_id"
    t.index ["active"], name: "index_result_statistic_section_types_measures_on_active"
    t.index ["deleted_at"], name: "index_result_statistic_section_types_measures_on_deleted_at"
    t.index ["measure_id"], name: "index_rsstm_on_m_id"
    t.index ["result_statistic_section_type_id"], name: "index_rsstm_on_rsst_id"
    t.index ["result_statistic_section_types_measure_id"], name: "index_rsstm_on_rsstm_id"
    t.index ["type1_type_id"], name: "index_result_statistic_section_types_measures_on_type1_type_id"
  end

  create_table "result_statistic_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "result_statistic_section_type_id"
    t.integer "population_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_result_statistic_sections_on_deleted_at"
    t.index ["population_id"], name: "index_result_statistic_sections_on_population_id"
    t.index ["result_statistic_section_type_id", "population_id", "deleted_at"], name: "index_rss_on_rsst_id_eefpst1rc_id_uniq", unique: true
    t.index ["result_statistic_section_type_id"], name: "index_rss_on_rsst_id"
  end

  create_table "result_statistic_sections_measures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "measure_id"
    t.integer "result_statistic_section_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "result_statistic_sections_measure_id"
    t.index ["active"], name: "index_result_statistic_sections_measures_on_active"
    t.index ["deleted_at"], name: "index_result_statistic_sections_measures_on_deleted_at"
    t.index ["measure_id", "result_statistic_section_id", "active"], name: "index_rssm_on_m_id_rss_id_active"
    t.index ["measure_id", "result_statistic_section_id", "deleted_at"], name: "index_rssm_on_m_id_rss_id_deleted_at"
    t.index ["measure_id"], name: "index_result_statistic_sections_measures_on_measure_id"
    t.index ["result_statistic_section_id"], name: "index_rssm_on_rss_id"
    t.index ["result_statistic_sections_measure_id"], name: "index_rssm_on_rssm_id"
  end

  create_table "result_statistic_sections_measures_comparisons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "result_statistic_section_id"
    t.integer "comparison_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comparison_id"], name: "index_rssmc_on_comparison_id"
    t.index ["result_statistic_section_id"], name: "index_rssmc_on_rss_id"
  end

  create_table "review_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_roles_on_deleted_at"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "screening_option_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "screening_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "label_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.integer "screening_option_type_id"
    t.index ["label_type_id"], name: "index_screening_options_on_label_type_id"
    t.index ["project_id"], name: "index_screening_options_on_project_id"
    t.index ["screening_option_type_id"], name: "index_screening_options_on_screening_option_type_id"
  end

  create_table "sd_analytic_frameworks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_analytic_frameworks_on_sd_meta_datum_id"
  end

  create_table "sd_evidence_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sd_result_item_id"
    t.index ["sd_result_item_id"], name: "index_sd_evidence_tables_on_sd_result_item_id"
  end

  create_table "sd_grey_literature_searches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_grey_literature_searches_on_sd_meta_datum_id"
  end

  create_table "sd_journal_article_urls", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_journal_article_urls_on_sd_meta_datum_id"
  end

  create_table "sd_key_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.integer "sd_key_question_id"
    t.integer "key_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "includes_meta_analysis"
    t.index ["key_question_id"], name: "index_sd_key_questions_on_key_question_id"
    t.index ["sd_key_question_id"], name: "index_sd_key_questions_on_sd_key_question_id"
    t.index ["sd_meta_datum_id"], name: "index_sd_key_questions_on_sd_meta_datum_id"
  end

  create_table "sd_key_questions_key_question_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sd_key_question_id"
    t.bigint "key_question_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_question_type_id"], name: "index_kq_types"
    t.index ["sd_key_question_id", "key_question_type_id"], name: "index_sd_kqs_kq_types"
    t.index ["sd_key_question_id"], name: "index_sd_kqs"
  end

  create_table "sd_key_questions_projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_key_question_id"
    t.integer "key_questions_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_questions_project_id"], name: "index_sd_key_questions_projects_on_key_questions_project_id"
    t.index ["sd_key_question_id"], name: "index_sd_key_questions_projects_on_sd_key_question_id"
  end

  create_table "sd_key_questions_sd_picods", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_key_question_id"
    t.integer "sd_picod_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_key_question_id"], name: "index_sd_key_questions_sd_picods_on_sd_key_question_id"
    t.index ["sd_picod_id"], name: "index_sd_key_questions_sd_picods_on_sd_picod_id"
  end

  create_table "sd_meta_data", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.string "report_title"
    t.datetime "date_of_last_search"
    t.datetime "date_of_publication_to_srdr"
    t.datetime "date_of_publication_full_report"
    t.text "authors_conflict_of_interest_of_full_report"
    t.text "protocol_link"
    t.text "full_report_link"
    t.text "structured_abstract_link"
    t.text "key_messages_link"
    t.text "abstract_summary_link"
    t.text "evidence_summary_link"
    t.text "disposition_of_comments_link"
    t.text "srdr_data_link"
    t.text "most_previous_version_srdr_link"
    t.text "most_previous_version_full_report_link"
    t.text "overall_purpose_of_review"
    t.string "state", default: "DRAFT", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "section_flag_0", default: false, null: false
    t.boolean "section_flag_1", default: false, null: false
    t.boolean "section_flag_2", default: false, null: false
    t.boolean "section_flag_3", default: false, null: false
    t.boolean "section_flag_4", default: false, null: false
    t.boolean "section_flag_5", default: false, null: false
    t.boolean "section_flag_6", default: false, null: false
    t.string "report_accession_id"
    t.text "authors"
    t.boolean "section_flag_7", default: false, null: false
    t.string "prospero_link"
    t.bigint "review_type_id"
    t.text "stakeholders_key_informants"
    t.text "stakeholders_technical_experts"
    t.text "stakeholders_peer_reviewers"
    t.text "stakeholders_others"
    t.boolean "section_flag_8", default: false, null: false
    t.text "organization"
    t.index ["review_type_id"], name: "index_sd_meta_data_on_review_type_id"
  end

  create_table "sd_meta_data_figures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sd_figurable_id"
    t.string "sd_figurable_type"
    t.string "p_type"
    t.text "alt_text"
    t.index ["sd_figurable_id", "sd_figurable_type"], name: "index_sd_analysis_figures_on_type_id"
  end

  create_table "sd_meta_data_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "query_text"
    t.bigint "sd_meta_datum_id"
    t.bigint "projects_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["projects_user_id"], name: "index_sd_meta_data_queries_on_projects_user_id"
    t.index ["sd_meta_datum_id"], name: "index_sd_meta_data_queries_on_sd_meta_datum_id"
  end

  create_table "sd_meta_regression_analysis_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sd_result_item_id"
    t.index ["sd_result_item_id"], name: "index_sd_meta_regression_analysis_results_on_sd_result_item_id"
  end

  create_table "sd_narrative_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "narrative_results"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "narrative_results_by_population"
    t.text "narrative_results_by_intervention"
    t.bigint "sd_result_item_id"
    t.index ["sd_result_item_id"], name: "index_sd_narrative_results_on_sd_result_item_id"
  end

  create_table "sd_network_meta_analysis_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sd_result_item_id"
    t.index ["sd_result_item_id"], name: "index_sd_network_meta_analysis_results_on_sd_result_item_id"
  end

  create_table "sd_other_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_other_items_on_sd_meta_datum_id"
  end

  create_table "sd_outcomes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "sd_outcomeable_id"
    t.string "sd_outcomeable_type"
    t.datetime "deleted_at"
    t.index ["name"], name: "index_sd_outcomes_on_name"
    t.index ["sd_outcomeable_id", "sd_outcomeable_type"], name: "index_sd_outcomes_on_sd_outcomeable_id_and_sd_outcomeable_type"
    t.index ["sd_outcomeable_type", "sd_outcomeable_id", "name"], name: "index_sd_outcomes_on_type_id_name", unique: true
  end

  create_table "sd_pairwise_meta_analytic_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sd_result_item_id"
    t.index ["sd_result_item_id"], name: "index_sd_pairwise_meta_analytic_results_on_sd_result_item_id"
  end

  create_table "sd_picods", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "population"
    t.text "interventions"
    t.text "comparators"
    t.text "outcomes"
    t.text "study_designs"
    t.text "settings"
    t.bigint "data_analysis_level_id"
    t.text "timing"
    t.text "other_elements"
    t.index ["data_analysis_level_id"], name: "index_sd_picods_on_data_analysis_level_id"
    t.index ["sd_meta_datum_id"], name: "index_sd_picods_on_sd_meta_datum_id"
  end

  create_table "sd_picods_sd_picods_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_picod_id"
    t.integer "sd_picods_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_picod_id"], name: "index_sdspt_sd_picod"
    t.index ["sd_picods_type_id"], name: "index_sdspt_sd_picod_type"
  end

  create_table "sd_picods_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sd_prisma_flows", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_prisma_flows_on_sd_meta_datum_id"
  end

  create_table "sd_project_leads", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_project_leads_on_sd_meta_datum_id"
    t.index ["user_id"], name: "index_sd_project_leads_on_user_id"
  end

  create_table "sd_result_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sd_key_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sd_meta_datum_id"
    t.index ["sd_key_question_id"], name: "index_sd_result_items_on_sd_key_question_id"
    t.index ["sd_meta_datum_id"], name: "index_sd_result_items_on_sd_meta_datum_id"
  end

  create_table "sd_search_databases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sd_search_strategies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.integer "sd_search_database_id"
    t.string "date_of_search"
    t.text "search_limits"
    t.text "search_terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_meta_datum_id"], name: "index_sd_search_strategies_on_sd_meta_datum_id"
    t.index ["sd_search_database_id"], name: "index_sd_search_strategies_on_sd_search_database_id"
  end

  create_table "sd_summary_of_evidences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sd_meta_datum_id"
    t.integer "sd_key_question_id"
    t.text "name"
    t.string "soe_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sd_key_question_id"], name: "index_sd_summary_of_evidences_on_sd_key_question_id"
    t.index ["sd_meta_datum_id"], name: "index_sd_summary_of_evidences_on_sd_meta_datum_id"
  end

  create_table "searchjoy_searches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "search_type"
    t.string "query"
    t.string "normalized_query"
    t.integer "results_count"
    t.datetime "created_at"
    t.string "convertable_type"
    t.integer "convertable_id"
    t.datetime "converted_at"
    t.index ["convertable_type", "convertable_id"], name: "index_searchjoy_searches_on_convertable_type_and_convertable_id"
    t.index ["created_at"], name: "index_searchjoy_searches_on_created_at"
    t.index ["search_type", "created_at"], name: "index_searchjoy_searches_on_search_type_and_created_at"
    t.index ["search_type", "normalized_query", "created_at"], name: "index_searchjoy_searches_on_search_type_query"
    t.index ["user_id"], name: "index_searchjoy_searches_on_user_id"
  end

  create_table "secondary_publication_numbers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "secondary_publication_id"
    t.string "number"
    t.string "number_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "secondary_publications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.text "title"
    t.text "author"
    t.string "country"
    t.string "year"
    t.string "association"
    t.integer "display_number"
    t.integer "extraction_form_id"
    t.string "pmid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "journal"
    t.string "volume"
    t.string "issue"
    t.string "trial_title"
    t.index ["study_id"], name: "secondarypublication_study_idx"
  end

  create_table "sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "default", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["default"], name: "index_sections_on_default"
    t.index ["deleted_at"], name: "index_sections_on_deleted_at"
    t.index ["name"], name: "index_sections_on_name", unique: true
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "srdr_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.date "eventdate"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "srdr_quality_improvement_questionnaires", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "q1_first"
    t.string "q1_last"
    t.string "q1_email"
    t.string "q1_can_followup"
    t.string "q2"
    t.string "q3_lead"
    t.string "q3_collaborator"
    t.string "q4"
    t.string "q5"
    t.string "q6_month"
    t.string "q6_year"
    t.string "q7_abstrackr"
    t.string "q7_openmeta"
    t.string "q7_distiller"
    t.string "q7_covidence"
    t.string "q7_docdata"
    t.string "q7_eros"
    t.string "q7_sumari"
    t.string "q7_cast"
    t.string "q7_rayyan"
    t.string "q7_revman"
    t.string "q7_other"
    t.string "q8"
    t.string "q9"
    t.string "q10"
    t.string "q11"
    t.string "q12a"
    t.string "q12b"
    t.string "q13"
    t.string "q14"
    t.string "q14_month"
    t.string "q14_year"
    t.string "q15"
    t.string "q16"
    t.string "q17a"
    t.string "q17b"
    t.string "q17c"
    t.string "q17d"
    t.string "q17e"
    t.string "q18"
    t.string "q19"
    t.string "q20a"
    t.string "q20b"
    t.string "q20c"
    t.string "q20d"
    t.string "q20e"
    t.string "q20f"
    t.string "q21"
    t.string "q22"
    t.string "q23a"
    t.string "q23b"
    t.string "q23c"
    t.string "q23d"
    t.string "q24"
    t.string "q25"
    t.string "q26"
    t.string "q26_month"
    t.string "q26_year"
    t.string "q27a"
    t.string "q27b"
    t.string "q27c"
    t.string "q28"
    t.string "q29"
    t.string "q30"
    t.string "q30_month"
    t.string "q30_year"
    t.string "q31a"
    t.string "q31b"
    t.string "q31c"
    t.string "q32"
    t.string "q33"
    t.string "q34"
    t.string "q34_month"
    t.string "q34_year"
    t.string "q35"
    t.string "q36"
    t.string "q37"
    t.string "q38"
    t.string "q38_month"
    t.string "q38_year"
    t.string "q39a"
    t.string "q39b"
    t.string "q39c"
    t.string "q39d"
    t.string "q40"
    t.string "q41"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stale_project_reminders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "enabled", default: true
    t.datetime "reminder_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "statusings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "statusable_type"
    t.bigint "statusable_id"
    t.bigint "status_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_statusings_on_active"
    t.index ["deleted_at"], name: "index_statusings_on_deleted_at"
    t.index ["status_id"], name: "index_statusings_on_status_id"
    t.index ["statusable_type", "statusable_id", "status_id", "active"], name: "index_statusings_on_type_id_status_id_active_uniq", unique: true
    t.index ["statusable_type", "statusable_id", "status_id", "deleted_at"], name: "index_statusings_on_type_id_status_id_deleted_at_uniq", unique: true
    t.index ["statusable_type", "statusable_id"], name: "index_statusings_on_statusable_type_and_statusable_id"
  end

  create_table "studies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_extraction_forms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["study_id"], name: "EDIT_TAB"
  end

  create_table "study_key_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "study_id"
    t.integer "key_question_id"
    t.integer "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["study_id"], name: "EDIT_TAB"
    t.index ["study_id"], name: "studykeyquestiony_study_idx"
  end

  create_table "study_status_notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "study_id"
    t.integer "extraction_form_id"
    t.integer "user_id"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggestions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "suggestable_type"
    t.integer "suggestable_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_suggestions_on_active"
    t.index ["deleted_at"], name: "index_suggestions_on_deleted_at"
    t.index ["suggestable_type", "suggestable_id", "user_id", "active"], name: "index_suggestions_on_type_id_user_id_active_uniq", unique: true
    t.index ["suggestable_type", "suggestable_id", "user_id", "deleted_at"], name: "index_suggestions_on_type_id_user_id_deleted_at_uniq", unique: true
    t.index ["suggestable_type", "suggestable_id"], name: "index_suggestions_on_suggestable_type_and_suggestable_id"
    t.index ["user_id"], name: "index_suggestions_on_user_id"
  end

  create_table "taggings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "projects_users_role_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_taggings_on_deleted_at"
    t.index ["projects_users_role_id"], name: "index_taggings_on_projects_users_role_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_tags_on_deleted_at"
  end

  create_table "task_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "task_type_id"
    t.integer "project_id"
    t.integer "num_assigned"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "required_inclusion_reason", default: false
    t.boolean "required_exclusion_reason", default: false
    t.boolean "required_maybe_reason", default: false
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
  end

  create_table "team_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "team_type_id"
    t.integer "project_id"
    t.boolean "enabled"
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
    t.index ["project_id"], name: "index_teams_on_project_id"
    t.index ["team_type_id"], name: "index_teams_on_team_type_id"
  end

  create_table "term_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "term_groups_colors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "term_group_id"
    t.integer "color_id"
    t.index ["color_id"], name: "index_term_groups_colors_on_color_id"
    t.index ["term_group_id"], name: "index_term_groups_colors_on_term_group_id"
  end

  create_table "terms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
  end

  create_table "timepoint_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "unit", default: "", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "isValidUCUM", default: false
    t.boolean "isValidUCUMTested", default: false
    t.index ["deleted_at"], name: "index_timepoint_names_on_deleted_at"
  end

  create_table "tps_arms_rssms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "timepoint_id"
    t.integer "extractions_extraction_forms_projects_sections_type1_id"
    t.integer "result_statistic_sections_measure_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tps_arms_rssms_on_active"
    t.index ["deleted_at"], name: "index_tps_arms_rssms_on_deleted_at"
    t.index ["extractions_extraction_forms_projects_sections_type1_id"], name: "index_tps_arms_rssms_on_eefpst_id"
    t.index ["result_statistic_sections_measure_id"], name: "index_tps_arms_rssms_on_rssm_id"
    t.index ["timepoint_id"], name: "index_tps_arms_rssms_on_timepoint_id"
  end

  create_table "tps_comparisons_rssms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "timepoint_id"
    t.integer "comparison_id"
    t.integer "result_statistic_sections_measure_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tps_comparisons_rssms_on_active"
    t.index ["comparison_id"], name: "index_tps_comparisons_rssms_on_comparison_id"
    t.index ["deleted_at"], name: "index_tps_comparisons_rssms_on_deleted_at"
    t.index ["result_statistic_sections_measure_id"], name: "index_tps_comparisons_rssms_on_rssm_id"
    t.index ["timepoint_id"], name: "index_tps_comparisons_rssms_on_timepoint_id"
  end

  create_table "trial_participant_infos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "age"
    t.boolean "readEnglish"
    t.boolean "experienceExtractingData"
    t.string "experienceLevel"
    t.string "articlesExtracted"
    t.string "email"
    t.string "submissionToken"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "hasPublished"
    t.text "followUpQuestionOne"
    t.text "recentExtraction"
    t.text "trainingType"
    t.text "currentStatus"
  end

  create_table "type1_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_type1_types_on_deleted_at"
  end

  create_table "type1s", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_type1s_on_deleted_at"
    t.index ["name", "description", "deleted_at"], name: "index_type1s_on_name_and_description_and_deleted_at", unique: true, length: { description: 255 }
  end

  create_table "user_organization_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "role"
    t.string "status"
    t.boolean "notify"
    t.boolean "add_internal_comments"
    t.boolean "view_internal_comments"
    t.boolean "publish"
    t.boolean "certified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_id"
  end

  create_table "user_project_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "user_type_id"
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.string "refresh_token"
    t.string "api_key"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email", "deleted_at"], name: "index_users_on_email_and_deleted_at", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["user_type_id"], name: "index_users_on_user_type_id"
  end

  create_table "wacs_bacs_rssms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "wac_id"
    t.integer "bac_id"
    t.integer "result_statistic_sections_measure_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_wacs_bacs_rssms_on_active"
    t.index ["bac_id"], name: "index_wacs_bacs_rssms_on_bac_id"
    t.index ["deleted_at"], name: "index_wacs_bacs_rssms_on_deleted_at"
    t.index ["result_statistic_sections_measure_id"], name: "index_wacs_bacs_rssms_on_result_statistic_sections_measure_id"
    t.index ["wac_id"], name: "index_wacs_bacs_rssms_on_wac_id"
  end

  add_foreign_key "abstrackr_settings", "profiles"
  add_foreign_key "actions", "action_types"
  add_foreign_key "actions", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "approvals", "users"
  add_foreign_key "assignments", "projects_users_roles"
  add_foreign_key "assignments", "tasks"
  add_foreign_key "assignments", "users"
  add_foreign_key "citations", "citation_types"
  add_foreign_key "citations_projects", "citations"
  add_foreign_key "citations_projects", "consensus_types"
  add_foreign_key "citations_projects", "projects"
  add_foreign_key "citations_tasks", "citations"
  add_foreign_key "citations_tasks", "tasks"
  add_foreign_key "colorings", "color_choices"
  add_foreign_key "comparate_groups", "comparisons"
  add_foreign_key "comparates", "comparable_elements"
  add_foreign_key "comparates", "comparate_groups"
  add_foreign_key "comparisons_arms_rssms", "comparisons"
  add_foreign_key "comparisons_arms_rssms", "extractions_extraction_forms_projects_sections_type1s"
  add_foreign_key "comparisons_arms_rssms", "result_statistic_sections_measures"
  add_foreign_key "comparisons_measures", "comparisons"
  add_foreign_key "comparisons_measures", "measures"
  add_foreign_key "comparisons_result_statistic_sections", "comparisons"
  add_foreign_key "comparisons_result_statistic_sections", "result_statistic_sections"
  add_foreign_key "degrees_profiles", "degrees"
  add_foreign_key "degrees_profiles", "profiles"
  add_foreign_key "dispatches", "users"
  add_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections"
  add_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections_type1s"
  add_foreign_key "eefps_qrcfs", "question_row_column_fields"
  add_foreign_key "eefpsqrcf_qrcqrcos", "eefps_qrcfs"
  add_foreign_key "eefpsqrcf_qrcqrcos", "question_row_columns_question_row_column_options"
  add_foreign_key "exported_files", "file_types"
  add_foreign_key "exported_files", "projects"
  add_foreign_key "exported_files", "users"
  add_foreign_key "exported_items", "export_types"
  add_foreign_key "exported_items", "projects_users"
  add_foreign_key "extraction_forms_projects", "extraction_forms"
  add_foreign_key "extraction_forms_projects", "extraction_forms_project_types"
  add_foreign_key "extraction_forms_projects", "projects"
  add_foreign_key "extraction_forms_projects_section_options", "extraction_forms_projects_sections"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_section_types"
  add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_sections"
  add_foreign_key "extraction_forms_projects_sections", "sections"
  add_foreign_key "extraction_forms_projects_sections_type1s", "extraction_forms_projects_sections"
  add_foreign_key "extraction_forms_projects_sections_type1s", "type1_types"
  add_foreign_key "extraction_forms_projects_sections_type1s", "type1s"
  add_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "extraction_forms_projects_sections_type1s"
  add_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "timepoint_names"
  add_foreign_key "extractions", "citations_projects"
  add_foreign_key "extractions", "projects"
  add_foreign_key "extractions", "projects_users_roles"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extractions"
  add_foreign_key "extractions_extraction_forms_projects_sections", "extractions_extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "extractions_extraction_forms_projects_sections_type1_rows"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "timepoint_names"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "extractions_extraction_forms_projects_sections_type1s"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "population_names"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "extractions_extraction_forms_projects_sections"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1_types"
  add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1s"
  add_foreign_key "extractions_projects_users_roles", "extractions"
  add_foreign_key "extractions_projects_users_roles", "projects_users_roles"
  add_foreign_key "funding_sources_sd_meta_data", "funding_sources"
  add_foreign_key "funding_sources_sd_meta_data", "sd_meta_data"
  add_foreign_key "imported_files", "file_types"
  add_foreign_key "imported_files", "sections"
  add_foreign_key "invitations", "roles"
  add_foreign_key "journals", "citations"
  add_foreign_key "key_questions_projects", "extraction_forms_projects_sections"
  add_foreign_key "key_questions_projects", "key_questions"
  add_foreign_key "key_questions_projects", "projects"
  add_foreign_key "key_questions_projects_questions", "key_questions_projects"
  add_foreign_key "key_questions_projects_questions", "questions"
  add_foreign_key "labels", "citations_projects"
  add_foreign_key "labels", "label_types"
  add_foreign_key "labels", "projects_users_roles"
  add_foreign_key "labels_reasons", "labels"
  add_foreign_key "labels_reasons", "projects_users_roles"
  add_foreign_key "labels_reasons", "reasons"
  add_foreign_key "measurements", "comparisons_measures"
  add_foreign_key "message_types", "frequencies"
  add_foreign_key "messages", "message_types"
  add_foreign_key "notes", "projects_users_roles"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "pending_invitations", "invitations"
  add_foreign_key "pending_invitations", "users"
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
  add_foreign_key "projects_users_roles_teams", "projects_users_roles"
  add_foreign_key "projects_users_roles_teams", "teams"
  add_foreign_key "projects_users_term_groups_colors", "projects_users"
  add_foreign_key "projects_users_term_groups_colors", "term_groups_colors"
  add_foreign_key "projects_users_term_groups_colors_terms", "projects_users_term_groups_colors"
  add_foreign_key "projects_users_term_groups_colors_terms", "terms"
  add_foreign_key "publishings", "users"
  add_foreign_key "quality_dimension_questions", "quality_dimension_sections"
  add_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_options"
  add_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_questions"
  add_foreign_key "question_row_column_fields", "question_row_columns"
  add_foreign_key "question_row_columns", "question_row_column_types"
  add_foreign_key "question_row_columns", "question_rows"
  add_foreign_key "question_row_columns_question_row_column_options", "question_row_column_options"
  add_foreign_key "question_row_columns_question_row_column_options", "question_row_columns"
  add_foreign_key "question_rows", "questions"
  add_foreign_key "questions", "extraction_forms_projects_sections"
  add_foreign_key "reasons", "label_types"
  add_foreign_key "result_statistic_section_types_measures", "measures"
  add_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types"
  add_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types_measures"
  add_foreign_key "result_statistic_section_types_measures", "type1_types"
  add_foreign_key "result_statistic_sections", "extractions_extraction_forms_projects_sections_type1_rows", column: "population_id"
  add_foreign_key "result_statistic_sections", "result_statistic_section_types"
  add_foreign_key "result_statistic_sections_measures", "measures"
  add_foreign_key "result_statistic_sections_measures", "result_statistic_sections"
  add_foreign_key "result_statistic_sections_measures", "result_statistic_sections_measures"
  add_foreign_key "result_statistic_sections_measures_comparisons", "comparisons"
  add_foreign_key "result_statistic_sections_measures_comparisons", "result_statistic_sections"
  add_foreign_key "screening_options", "label_types"
  add_foreign_key "screening_options", "projects"
  add_foreign_key "screening_options", "screening_option_types"
  add_foreign_key "sd_analytic_frameworks", "sd_meta_data"
  add_foreign_key "sd_grey_literature_searches", "sd_meta_data"
  add_foreign_key "sd_journal_article_urls", "sd_meta_data"
  add_foreign_key "sd_key_questions", "key_questions"
  add_foreign_key "sd_key_questions", "sd_key_questions"
  add_foreign_key "sd_key_questions", "sd_meta_data"
  add_foreign_key "sd_key_questions_projects", "key_questions_projects"
  add_foreign_key "sd_key_questions_projects", "sd_key_questions"
  add_foreign_key "sd_key_questions_sd_picods", "sd_key_questions"
  add_foreign_key "sd_key_questions_sd_picods", "sd_picods"
  add_foreign_key "sd_meta_data", "review_types"
  add_foreign_key "sd_other_items", "sd_meta_data"
  add_foreign_key "sd_picods", "data_analysis_levels"
  add_foreign_key "sd_picods", "sd_meta_data"
  add_foreign_key "sd_picods_sd_picods_types", "sd_picods"
  add_foreign_key "sd_picods_sd_picods_types", "sd_picods_types"
  add_foreign_key "sd_prisma_flows", "sd_meta_data"
  add_foreign_key "sd_project_leads", "sd_meta_data"
  add_foreign_key "sd_project_leads", "users"
  add_foreign_key "sd_search_strategies", "sd_meta_data"
  add_foreign_key "sd_search_strategies", "sd_search_databases"
  add_foreign_key "sd_summary_of_evidences", "sd_key_questions"
  add_foreign_key "sd_summary_of_evidences", "sd_meta_data"
  add_foreign_key "statusings", "statuses"
  add_foreign_key "suggestions", "users"
  add_foreign_key "taggings", "projects_users_roles"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "task_types"
  add_foreign_key "teams", "projects"
  add_foreign_key "teams", "team_types"
  add_foreign_key "term_groups_colors", "colors"
  add_foreign_key "term_groups_colors", "term_groups"
  add_foreign_key "tps_arms_rssms", "extractions_extraction_forms_projects_sections_type1_row_columns", column: "timepoint_id"
  add_foreign_key "tps_arms_rssms", "extractions_extraction_forms_projects_sections_type1s"
  add_foreign_key "tps_arms_rssms", "result_statistic_sections_measures"
  add_foreign_key "tps_comparisons_rssms", "comparisons"
  add_foreign_key "tps_comparisons_rssms", "extractions_extraction_forms_projects_sections_type1_row_columns", column: "timepoint_id"
  add_foreign_key "tps_comparisons_rssms", "result_statistic_sections_measures"
  add_foreign_key "users", "user_types"
  add_foreign_key "wacs_bacs_rssms", "result_statistic_sections_measures"
end
