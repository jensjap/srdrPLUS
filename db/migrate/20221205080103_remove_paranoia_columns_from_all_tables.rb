class RemoveParanoiaColumnsFromAllTables < ActiveRecord::Migration[7.0]
  def change
    # STEP 1
    remove_foreign_key "abstrackr_settings", "profiles", if_exists: true
    remove_foreign_key "actions", "action_types", if_exists: true
    remove_foreign_key "actions", "users", if_exists: true
    remove_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", if_exists: true
    remove_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", if_exists: true
    remove_foreign_key "approvals", "users", if_exists: true
    remove_foreign_key "assignments", "projects_users_roles", if_exists: true
    remove_foreign_key "assignments", "tasks", if_exists: true
    remove_foreign_key "assignments", "users", if_exists: true
    remove_foreign_key "citations", "citation_types", if_exists: true
    remove_foreign_key "citations_projects", "citations", if_exists: true
    remove_foreign_key "citations_projects", "consensus_types", if_exists: true
    remove_foreign_key "citations_projects", "projects", if_exists: true
    remove_foreign_key "citations_tasks", "citations", if_exists: true
    remove_foreign_key "citations_tasks", "tasks", if_exists: true
    remove_foreign_key "colorings", "color_choices", if_exists: true
    remove_foreign_key "comparate_groups", "comparisons", if_exists: true
    remove_foreign_key "comparates", "comparable_elements", if_exists: true
    remove_foreign_key "comparates", "comparate_groups", if_exists: true
    remove_foreign_key "comparisons_arms_rssms", "comparisons", if_exists: true
    remove_foreign_key "comparisons_arms_rssms", "extractions_extraction_forms_projects_sections_type1s", if_exists: true
    remove_foreign_key "comparisons_arms_rssms", "result_statistic_sections_measures", if_exists: true
    remove_foreign_key "comparisons_measures", "comparisons", if_exists: true
    remove_foreign_key "comparisons_measures", "measures", if_exists: true
    remove_foreign_key "comparisons_result_statistic_sections", "comparisons", if_exists: true
    remove_foreign_key "comparisons_result_statistic_sections", "result_statistic_sections", if_exists: true
    remove_foreign_key "degrees_profiles", "degrees", if_exists: true
    remove_foreign_key "degrees_profiles", "profiles", if_exists: true
    remove_foreign_key "dispatches", "users", if_exists: true
    remove_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections_type1s", if_exists: true
    remove_foreign_key "eefps_qrcfs", "question_row_column_fields", if_exists: true
    remove_foreign_key "eefpsqrcf_qrcqrcos", "eefps_qrcfs", if_exists: true
    remove_foreign_key "eefpsqrcf_qrcqrcos", "question_row_columns_question_row_column_options", if_exists: true
    remove_foreign_key "exported_files", "file_types", if_exists: true
    remove_foreign_key "exported_files", "projects", if_exists: true
    remove_foreign_key "exported_files", "users", if_exists: true
    remove_foreign_key "exported_items", "export_types", if_exists: true
    remove_foreign_key "extraction_forms_projects", "extraction_forms", if_exists: true
    remove_foreign_key "extraction_forms_projects", "extraction_forms_project_types", if_exists: true
    remove_foreign_key "extraction_forms_projects", "projects", if_exists: true
    remove_foreign_key "extraction_forms_projects_section_options", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_section_types", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections", "sections", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections_type1s", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections_type1s", "type1_types", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections_type1s", "type1s", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "extraction_forms_projects_sections_type1s", if_exists: true
    remove_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "timepoint_names", if_exists: true
    remove_foreign_key "extractions", "citations_projects", if_exists: true
    remove_foreign_key "extractions", "projects", if_exists: true
    remove_foreign_key "extractions", "projects_users_roles", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections", "extractions", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections", "extractions_extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "extractions_extraction_forms_projects_sections_type1_rows", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "timepoint_names", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "extractions_extraction_forms_projects_sections_type1s", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "population_names", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1s", "extractions_extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1_types", if_exists: true
    remove_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1s", if_exists: true
    remove_foreign_key "funding_sources_sd_meta_data", "funding_sources", if_exists: true
    remove_foreign_key "funding_sources_sd_meta_data", "sd_meta_data", if_exists: true
    remove_foreign_key "imported_files", "file_types", if_exists: true
    remove_foreign_key "imported_files", "sections", if_exists: true
    remove_foreign_key "invitations", "roles", if_exists: true
    remove_foreign_key "journals", "citations", if_exists: true
    remove_foreign_key "key_questions_projects", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "key_questions_projects", "key_questions", if_exists: true
    remove_foreign_key "key_questions_projects", "projects", if_exists: true
    remove_foreign_key "key_questions_projects_questions", "key_questions_projects", if_exists: true
    remove_foreign_key "key_questions_projects_questions", "questions", if_exists: true
    remove_foreign_key "labels", "citations_projects", if_exists: true
    remove_foreign_key "labels", "label_types", if_exists: true
    remove_foreign_key "labels", "projects_users_roles", if_exists: true
    remove_foreign_key "labels_reasons", "labels", if_exists: true
    remove_foreign_key "labels_reasons", "projects_users_roles", if_exists: true
    remove_foreign_key "labels_reasons", "reasons", if_exists: true
    remove_foreign_key "measurements", "comparisons_measures", if_exists: true
    remove_foreign_key "message_types", "frequencies", if_exists: true
    remove_foreign_key "messages", "message_types", if_exists: true
    remove_foreign_key "notes", "projects_users_roles", if_exists: true
    remove_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", if_exists: true
    remove_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", if_exists: true
    remove_foreign_key "pending_invitations", "invitations", if_exists: true
    remove_foreign_key "pending_invitations", "users", if_exists: true
    remove_foreign_key "predictions", "citations_projects", if_exists: true
    remove_foreign_key "priorities", "citations_projects", if_exists: true
    remove_foreign_key "profiles", "organizations", if_exists: true
    remove_foreign_key "profiles", "users", if_exists: true
    remove_foreign_key "projects_users", "projects", if_exists: true
    remove_foreign_key "projects_users", "users", if_exists: true
    remove_foreign_key "projects_users_roles", "projects_users", if_exists: true
    remove_foreign_key "projects_users_roles", "roles", if_exists: true
    remove_foreign_key "projects_users_roles_teams", "projects_users_roles", if_exists: true
    remove_foreign_key "projects_users_roles_teams", "teams", if_exists: true
    remove_foreign_key "projects_users_term_groups_colors", "projects_users", if_exists: true
    remove_foreign_key "projects_users_term_groups_colors", "term_groups_colors", if_exists: true
    remove_foreign_key "projects_users_term_groups_colors_terms", "projects_users_term_groups_colors", if_exists: true
    remove_foreign_key "projects_users_term_groups_colors_terms", "terms", if_exists: true
    remove_foreign_key "publishings", "users", if_exists: true
    remove_foreign_key "quality_dimension_questions", "quality_dimension_sections", if_exists: true
    remove_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_options", if_exists: true
    remove_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_questions", if_exists: true
    remove_foreign_key "question_row_column_fields", "question_row_columns", if_exists: true
    remove_foreign_key "question_row_columns", "question_row_column_types", if_exists: true
    remove_foreign_key "question_row_columns", "question_rows", if_exists: true
    remove_foreign_key "question_row_columns_question_row_column_options", "question_row_column_options", if_exists: true
    remove_foreign_key "question_row_columns_question_row_column_options", "question_row_columns", if_exists: true
    remove_foreign_key "question_rows", "questions", if_exists: true
    remove_foreign_key "questions", "extraction_forms_projects_sections", if_exists: true
    remove_foreign_key "reasons", "label_types", if_exists: true
    remove_foreign_key "result_statistic_section_types_measures", "measures", if_exists: true
    remove_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types", if_exists: true
    remove_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types_measures", if_exists: true
    remove_foreign_key "result_statistic_section_types_measures", "type1_types", if_exists: true
    remove_foreign_key "result_statistic_sections", "extractions_extraction_forms_projects_sections_type1_rows", column: "population_id", if_exists: true
    remove_foreign_key "result_statistic_sections", "result_statistic_section_types", if_exists: true
    remove_foreign_key "result_statistic_sections_measures", "measures", if_exists: true
    remove_foreign_key "result_statistic_sections_measures", "result_statistic_sections", if_exists: true
    remove_foreign_key "result_statistic_sections_measures", "result_statistic_sections_measures", if_exists: true
    remove_foreign_key "result_statistic_sections_measures_comparisons", "comparisons", if_exists: true
    remove_foreign_key "result_statistic_sections_measures_comparisons", "result_statistic_sections", if_exists: true
    remove_foreign_key "screening_options", "label_types", if_exists: true
    remove_foreign_key "screening_options", "projects", if_exists: true
    remove_foreign_key "screening_options", "screening_option_types", if_exists: true
    remove_foreign_key "sd_analytic_frameworks", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_grey_literature_searches", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_journal_article_urls", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_key_questions", "key_questions", if_exists: true
    remove_foreign_key "sd_key_questions", "sd_key_questions", if_exists: true
    remove_foreign_key "sd_key_questions", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_key_questions_projects", "key_questions_projects", if_exists: true
    remove_foreign_key "sd_key_questions_projects", "sd_key_questions", if_exists: true
    remove_foreign_key "sd_key_questions_sd_picods", "sd_key_questions", if_exists: true
    remove_foreign_key "sd_key_questions_sd_picods", "sd_picods", if_exists: true
    remove_foreign_key "sd_meta_data", "review_types", if_exists: true
    remove_foreign_key "sd_other_items", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_picods", "data_analysis_levels", if_exists: true
    remove_foreign_key "sd_picods", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_picods_sd_picods_types", "sd_picods", if_exists: true
    remove_foreign_key "sd_picods_sd_picods_types", "sd_picods_types", if_exists: true
    remove_foreign_key "sd_prisma_flows", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_project_leads", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_project_leads", "users", if_exists: true
    remove_foreign_key "sd_search_strategies", "sd_meta_data", if_exists: true
    remove_foreign_key "sd_search_strategies", "sd_search_databases", if_exists: true
    remove_foreign_key "sd_summary_of_evidences", "sd_key_questions", if_exists: true
    remove_foreign_key "sd_summary_of_evidences", "sd_meta_data", if_exists: true
    remove_foreign_key "statusings", "statuses", if_exists: true
    remove_foreign_key "suggestions", "users", if_exists: true
    remove_foreign_key "taggings", "projects_users_roles", if_exists: true
    remove_foreign_key "taggings", "tags", if_exists: true
    remove_foreign_key "tasks", "projects", if_exists: true
    remove_foreign_key "tasks", "task_types", if_exists: true
    remove_foreign_key "teams", "projects", if_exists: true
    remove_foreign_key "teams", "team_types", if_exists: true
    remove_foreign_key "term_groups_colors", "colors", if_exists: true
    remove_foreign_key "term_groups_colors", "term_groups", if_exists: true
    remove_foreign_key "tps_arms_rssms", "extractions_extraction_forms_projects_sections_type1s", if_exists: true
    remove_foreign_key "tps_arms_rssms", "result_statistic_sections_measures", if_exists: true
    remove_foreign_key "tps_comparisons_rssms", "comparisons", if_exists: true
    remove_foreign_key "tps_comparisons_rssms", "result_statistic_sections_measures", if_exists: true
    remove_foreign_key "users", "user_types", if_exists: true
    remove_foreign_key "wacs_bacs_rssms", "result_statistic_sections_measures", if_exists: true

    # STEP 2
    remove_index :approvals, name: 'index_approvals_on_type_id_user_id_deleted_at_uniq', if_exists: true
    remove_index :approvals, name: 'index_approvals_on_type_id_user_id_active_uniq', if_exists: true
    remove_index :approvals, name: 'index_approvals_on_deleted_at', if_exists: true
    remove_index :approvals, name: 'index_approvals_on_active', if_exists: true
    remove_index :assignments, name: 'index_assignments_on_deleted_at', if_exists: true
    remove_index :authors, name: 'index_authors_on_deleted_at', if_exists: true
    remove_index :authors_citations, name: 'index_authors_citations_on_deleted_at', if_exists: true
    remove_index :citations, name: 'index_citations_on_deleted_at', if_exists: true
    remove_index :citations_projects, name: 'index_citations_projects_on_deleted_at', if_exists: true
    remove_index :citations_projects, name: 'index_citations_projects_on_active', if_exists: true
    remove_index :citations_projects, name: 'index_citations_projects_on_project_id_and_active', if_exists: true
    remove_index :citations_tasks, name: 'index_citations_tasks_on_deleted_at', if_exists: true
    remove_index :citations_tasks, name: 'index_citations_tasks_on_active', if_exists: true
    remove_index :comparable_elements, name: 'index_comparable_elements_on_deleted_at', if_exists: true
    remove_index :comparate_groups, name: 'index_comparate_groups_on_deleted_at', if_exists: true
    remove_index :comparates, name: 'index_comparates_on_deleted_at', if_exists: true
    remove_index :comparisons, name: 'index_comparisons_on_deleted_at', if_exists: true
    remove_index :comparisons_arms_rssms, name: 'index_comparisons_arms_rssms_on_deleted_at', if_exists: true
    remove_index :comparisons_arms_rssms, name: 'index_comparisons_arms_rssms_on_active', if_exists: true
    remove_index :comparisons_result_statistic_sections, name: 'index_comparisons_result_statistic_sections_on_deleted_at', if_exists: true
    remove_index :comparisons_result_statistic_sections, name: 'index_comparisons_result_statistic_sections_on_active', if_exists: true
    remove_index :comparisons_result_statistic_sections, name: 'index_crss_on_c_id_rss_id_deleted_at', if_exists: true
    remove_index :comparisons_result_statistic_sections, name: 'index_crss_on_c_id_rss_id_active', if_exists: true
    remove_index :degrees, name: 'index_degrees_on_deleted_at', if_exists: true
    remove_index :degrees_profiles, name: 'index_dp_on_d_id_p_id_deleted_at_uniq', if_exists: true
    remove_index :degrees_profiles, name: 'index_dp_on_d_id_p_id_active_uniq', if_exists: true
    remove_index :degrees_profiles, name: 'index_degrees_profiles_on_deleted_at', if_exists: true
    remove_index :degrees_profiles, name: 'index_degrees_profiles_on_active', if_exists: true
    remove_index :dependencies, name: 'index_dependencies_on_dtype_did_ptype_pid_deleted_at_uniq', if_exists: true
    remove_index :dependencies, name: 'index_dependencies_on_dtype_did_ptype_pid_active_uniq', if_exists: true
    remove_index :dependencies, name: 'index_dependencies_on_deleted_at', if_exists: true
    remove_index :dependencies, name: 'index_dependencies_on_active', if_exists: true
    remove_index :dispatches, name: 'index_dispatches_on_deleted_at', if_exists: true
    remove_index :dispatches, name: 'index_dispatches_on_active', if_exists: true
    remove_index :eefps_qrcfs, name: 'index_eefps_qrcfs_on_deleted_at', if_exists: true
    remove_index :eefps_qrcfs, name: 'index_eefps_qrcfs_on_active', if_exists: true
    remove_index :eefps_qrcfs, name: 'index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_deleted_at', if_exists: true
    remove_index :eefps_qrcfs, name: 'index_eefpsqrcf_on_eefpst1_id_eefps_id_qrcf_id_active', if_exists: true
    remove_index :eefpsqrcf_qrcqrcos, name: 'index_eefpsqrcf_qrcqrcos_on_deleted_at', if_exists: true
    remove_index :eefpsqrcf_qrcqrcos, name: 'index_eefpsqrcf_qrcqrcos_on_active', if_exists: true
    remove_index :eefpsqrcf_qrcqrcos, name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_deleted_at', if_exists: true
    remove_index :eefpsqrcf_qrcqrcos, name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id_qrcqrco_id_active', if_exists: true
    remove_index :extraction_checksums, name: 'index_extraction_checksums_on_deleted_at', if_exists: true
    remove_index :extraction_forms, name: 'index_extraction_forms_on_deleted_at', if_exists: true
    remove_index :extraction_forms_project_types, name: 'index_extraction_forms_project_types_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_extraction_forms_projects_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_extraction_forms_projects_on_active', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_ef_id_p_id_deleted_at', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_ef_id_p_id_active', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_efpt_id_ef_id_p_id_deleted_at', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_efpt_id_ef_id_p_id_active', if_exists: true
    remove_index :extraction_forms_projects_section_options, name: 'index_efpso_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_section_options, name: 'index_efpso_on_efps_id_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_section_types, name: 'index_extraction_forms_projects_section_types_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections, name: 'index_extraction_forms_projects_sections_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections, name: 'index_extraction_forms_projects_sections_on_active', if_exists: true
    remove_index :extraction_forms_projects_sections, name: 'index_efps_on_efp_id_efpst_id_s_id_efps_id_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections, name: 'index_efps_on_efp_id_efpst_id_s_id_efps_id_active', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s, name: 'index_efpst1_on_efps_id_t1_id_t1_type_id_deleted_at_uniq', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s, name: 'index_efpst1_on_efps_id_t1_id_t1_type_id_active_uniq', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s, name: 'index_extraction_forms_projects_sections_type1s_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s, name: 'index_extraction_forms_projects_sections_type1s_on_active', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s_timepoint_names, name: 'index_efpst1tn_on_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s_timepoint_names, name: 'index_efpst1tn_on_active', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s_timepoint_names, name: 'index_efpst1tn_on_efpst1_id_tn_id_deleted_at', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s_timepoint_names, name: 'index_efpst1tn_on_efpst1_id_tn_id_active', if_exists: true
    remove_index :extractions, name: 'index_e_on_p_id_cp_id_pur_id_deleted_at_uniq', if_exists: true
    remove_index :extractions, name: 'index_extractions_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections, name: 'index_eefps_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections, name: 'index_eefps_on_active', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections, name: 'index_eefps_on_e_id_efps_id_eefps_id_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections, name: 'index_eefps_on_e_id_efps_id_eefps_id_active', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_followup_fields, name: 'index_eefpsff_followup_fields_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_row_columns, name: 'index_eefpst1rc_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_row_columns, name: 'index_eefpst1rc_on_eefpst1r_id_tn_id_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_rows, name: 'index_eefpst1r_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_rows, name: 'index_eefpst1r_on_eefpst1_id_pn_id_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1s, name: 'index_eefpst1_on_t1t_id_eefps_id_t1_id_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1s, name: 'index_eefpst1_on_t1t_id_eefps_id_t1_id_active', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1s, name: 'index_eefpst1_on_deleted_at', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1s, name: 'index_eefpst1_on_active', if_exists: true
    remove_index :followup_fields, name: 'index_followup_fields_on_deleted_at', if_exists: true
    remove_index :frequencies, name: 'index_frequencies_on_deleted_at', if_exists: true
    remove_index :key_questions, name: 'index_key_questions_on_deleted_at', if_exists: true
    remove_index :key_questions_projects, name: 'index_key_questions_projects_on_deleted_at', if_exists: true
    remove_index :key_questions_projects, name: 'index_key_questions_projects_on_active', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_kq_id_p_id_deleted_at', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_kq_id_p_id_active', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_efps_id_kq_id_p_id_deleted_at', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_efps_id_kq_id_p_id_active', if_exists: true
    remove_index :keywords, name: 'index_keywords_on_deleted_at', if_exists: true
    remove_index :labels, name: 'index_labels_on_deleted_at', if_exists: true
    remove_index :labels_reasons, name: 'index_labels_reasons_on_deleted_at', if_exists: true
    remove_index :measures, name: 'index_measures_on_deleted_at', if_exists: true
    remove_index :message_types, name: 'index_message_types_on_deleted_at', if_exists: true
    remove_index :messages, name: 'index_messages_on_deleted_at', if_exists: true
    remove_index :notes, name: 'index_notes_on_deleted_at', if_exists: true
    remove_index :orderings, name: 'index_orderings_on_type_id_deleted_at_uniq', if_exists: true
    remove_index :orderings, name: 'index_orderings_on_type_id_active_uniq', if_exists: true
    remove_index :orderings, name: 'index_orderings_on_deleted_at', if_exists: true
    remove_index :orderings, name: 'index_orderings_on_active', if_exists: true
    remove_index :organizations, name: 'index_organizations_on_deleted_at', if_exists: true
    remove_index :population_names, name: 'index_population_names_on_deleted_at', if_exists: true
    remove_index :profiles, name: 'index_profiles_on_deleted_at', if_exists: true
    remove_index :projects, name: 'index_projects_on_deleted_at', if_exists: true
    remove_index :projects_users, name: 'index_pu_on_p_id_u_id_deleted_at_uniq', if_exists: true
    remove_index :projects_users, name: 'index_pu_on_p_id_u_id_active_uniq', if_exists: true
    remove_index :projects_users, name: 'index_projects_users_on_deleted_at', if_exists: true
    remove_index :projects_users, name: 'index_projects_users_on_active', if_exists: true
    remove_index :projects_users_roles, name: 'index_pur_on_pu_id_r_id_deleted_at_uniq', if_exists: true
    remove_index :projects_users_roles, name: 'index_pur_on_pu_id_r_id_active_uniq', if_exists: true
    remove_index :projects_users_roles, name: 'index_projects_users_roles_on_deleted_at', if_exists: true
    remove_index :projects_users_roles, name: 'index_projects_users_roles_on_active', if_exists: true
    remove_index :projects_users_roles_teams, name: 'index_projects_users_roles_teams_on_deleted_at', if_exists: true
    remove_index :projects_users_roles_teams, name: 'index_projects_users_roles_teams_on_active', if_exists: true
    remove_index :projects_users_term_groups_colors, name: 'index_projects_users_term_groups_colors_on_deleted_at', if_exists: true
    remove_index :projects_users_term_groups_colors_terms, name: 'index_projects_users_term_groups_colors_terms_on_deleted_at', if_exists: true
    remove_index :publishings, name: 'index_publishings_on_type_id_user_id_deleted_at_uniq', if_exists: true
    remove_index :publishings, name: 'index_publishings_on_type_id_user_id_active_uniq', if_exists: true
    remove_index :publishings, name: 'index_publishings_on_deleted_at', if_exists: true
    remove_index :publishings, name: 'index_publishings_on_active', if_exists: true
    remove_index :quality_dimension_options, name: 'index_quality_dimension_options_on_deleted_at', if_exists: true
    remove_index :quality_dimension_questions, name: 'index_quality_dimension_questions_on_deleted_at', if_exists: true
    remove_index :quality_dimension_questions_quality_dimension_options, name: 'index_qdq_id_qdo_id_active_uniq', if_exists: true
    remove_index :quality_dimension_sections, name: 'index_quality_dimension_sections_on_deleted_at', if_exists: true
    remove_index :question_row_column_fields, name: 'index_question_row_column_fields_on_deleted_at', if_exists: true
    remove_index :question_row_column_fields, name: 'index_qrcf_on_qrc_id_deleted_at', if_exists: true
    remove_index :question_row_column_options, name: 'index_question_row_column_options_on_deleted_at', if_exists: true
    remove_index :question_row_column_types, name: 'index_question_row_column_types_on_deleted_at', if_exists: true
    remove_index :question_row_columns, name: 'index_question_row_columns_on_deleted_at', if_exists: true
    remove_index :question_row_columns, name: 'index_qrc_on_qr_id_deleted_at', if_exists: true
    remove_index :question_row_columns, name: 'index_qrc_on_qr_id_qrct_id_deleted_at', if_exists: true
    remove_index :question_row_columns_question_row_column_options, name: 'index_qrcqrco_on_deleted_at', if_exists: true
    remove_index :question_row_columns_question_row_column_options, name: 'index_qrcqrco_on_active', if_exists: true
    remove_index :question_row_columns_question_row_column_options, name: 'index_qrcqrco_on_qrc_id_qrco_id_deleted_at', if_exists: true
    remove_index :question_row_columns_question_row_column_options, name: 'index_qrcqrco_on_qrc_id_qrco_id_active', if_exists: true
    remove_index :question_rows, name: 'index_question_rows_on_deleted_at', if_exists: true
    remove_index :question_rows, name: 'index_qr_on_q_id_deleted_at', if_exists: true
    remove_index :questions, name: 'index_questions_on_deleted_at', if_exists: true
    remove_index :questions, name: 'index_q_on_efps_id_deleted_at', if_exists: true
    remove_index :reasons, name: 'index_reasons_on_deleted_at', if_exists: true
    remove_index :records, name: 'index_records_on_deleted_at', if_exists: true
    remove_index :result_statistic_section_types, name: 'index_result_statistic_section_types_on_deleted_at', if_exists: true
    remove_index :result_statistic_section_types_measures, name: 'index_result_statistic_section_types_measures_on_deleted_at', if_exists: true
    remove_index :result_statistic_section_types_measures, name: 'index_result_statistic_section_types_measures_on_active', if_exists: true
    remove_index :result_statistic_sections, name: 'index_result_statistic_sections_on_deleted_at', if_exists: true
    remove_index :result_statistic_sections_measures, name: 'index_result_statistic_sections_measures_on_deleted_at', if_exists: true
    remove_index :result_statistic_sections_measures, name: 'index_result_statistic_sections_measures_on_active', if_exists: true
    remove_index :result_statistic_sections_measures, name: 'index_rssm_on_m_id_rss_id_deleted_at', if_exists: true
    remove_index :result_statistic_sections_measures, name: 'index_rssm_on_m_id_rss_id_active', if_exists: true
    remove_index :roles, name: 'index_roles_on_deleted_at', if_exists: true
    remove_index :sections, name: 'index_sections_on_deleted_at', if_exists: true
    remove_index :statusings, name: 'index_statusings_on_type_id_status_id_deleted_at_uniq', if_exists: true
    remove_index :statusings, name: 'index_statusings_on_type_id_status_id_active_uniq', if_exists: true
    remove_index :statusings, name: 'index_statusings_on_deleted_at', if_exists: true
    remove_index :statusings, name: 'index_statusings_on_active', if_exists: true
    remove_index :suggestions, name: 'index_suggestions_on_type_id_user_id_deleted_at_uniq', if_exists: true
    remove_index :suggestions, name: 'index_suggestions_on_type_id_user_id_active_uniq', if_exists: true
    remove_index :suggestions, name: 'index_suggestions_on_deleted_at', if_exists: true
    remove_index :suggestions, name: 'index_suggestions_on_active', if_exists: true
    remove_index :taggings, name: 'index_taggings_on_deleted_at', if_exists: true
    remove_index :tags, name: 'index_tags_on_deleted_at', if_exists: true
    remove_index :tasks, name: 'index_tasks_on_deleted_at', if_exists: true
    remove_index :teams, name: 'index_teams_on_deleted_at', if_exists: true
    remove_index :timepoint_names, name: 'index_timepoint_names_on_deleted_at', if_exists: true
    remove_index :tps_arms_rssms, name: 'index_tps_arms_rssms_on_deleted_at', if_exists: true
    remove_index :tps_arms_rssms, name: 'index_tps_arms_rssms_on_active', if_exists: true
    remove_index :tps_comparisons_rssms, name: 'index_tps_comparisons_rssms_on_deleted_at', if_exists: true
    remove_index :tps_comparisons_rssms, name: 'index_tps_comparisons_rssms_on_active', if_exists: true
    remove_index :type1_types, name: 'index_type1_types_on_deleted_at', if_exists: true
    remove_index :type1s, name: 'index_type1s_on_name_and_description_and_deleted_at', if_exists: true
    remove_index :type1s, name: 'index_type1s_on_deleted_at', if_exists: true
    remove_index :users, name: 'index_users_on_email_and_deleted_at', if_exists: true
    remove_index :users, name: 'index_users_on_deleted_at', if_exists: true
    remove_index :wacs_bacs_rssms, name: 'index_wacs_bacs_rssms_on_deleted_at', if_exists: true
    remove_index :wacs_bacs_rssms, name: 'index_wacs_bacs_rssms_on_active', if_exists: true

    # STEP 3
    remove_column :approvals, :active, if_exists: true
    remove_column :approvals, :deleted_at, if_exists: true
    remove_column :assignments, :deleted_at, if_exists: true
    remove_column :authors, :deleted_at, if_exists: true
    remove_column :authors_citations, :deleted_at, if_exists: true
    remove_column :citations, :deleted_at, if_exists: true
    remove_column :citations_projects, :active, if_exists: true
    remove_column :citations_projects, :deleted_at, if_exists: true
    remove_column :citations_tasks, :active, if_exists: true
    remove_column :citations_tasks, :deleted_at, if_exists: true
    remove_column :comparable_elements, :deleted_at, if_exists: true
    remove_column :comparate_groups, :deleted_at, if_exists: true
    remove_column :comparates, :deleted_at, if_exists: true
    remove_column :comparisons, :deleted_at, if_exists: true
    remove_column :comparisons_arms_rssms, :active, if_exists: true
    remove_column :comparisons_arms_rssms, :deleted_at, if_exists: true
    remove_column :comparisons_result_statistic_sections, :active, if_exists: true
    remove_column :comparisons_result_statistic_sections, :deleted_at, if_exists: true
    remove_column :degrees, :deleted_at, if_exists: true
    remove_column :degrees_profiles, :active, if_exists: true
    remove_column :degrees_profiles, :deleted_at, if_exists: true
    remove_column :dependencies, :active, if_exists: true
    remove_column :dependencies, :deleted_at, if_exists: true
    remove_column :dispatches, :active, if_exists: true
    remove_column :dispatches, :deleted_at, if_exists: true
    remove_column :extraction_forms, :deleted_at, if_exists: true
    remove_column :extraction_forms_project_types, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects, :active, if_exists: true
    remove_column :extraction_forms_projects, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects_section_options, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects_section_types, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects_sections, :active, if_exists: true
    remove_column :extraction_forms_projects_sections, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects_sections_type1s, :active, if_exists: true
    remove_column :extraction_forms_projects_sections_type1s, :deleted_at, if_exists: true
    remove_column :extraction_forms_projects_sections_type1s_timepoint_names, :active, if_exists: true
    remove_column :extraction_forms_projects_sections_type1s_timepoint_names, :deleted_at, if_exists: true
    remove_column :extractions, :deleted_at, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections, :active, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections, :deleted_at, if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_followup_fields, name: 'index_eefpsff_on_eefps_eefpst1_ff_id', if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_followup_fields, :active, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_followup_fields, :deleted_at, if_exists: true
    remove_column :eefps_qrcfs, :active, if_exists: true
    remove_column :eefps_qrcfs, :deleted_at, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_type1_row_columns, :deleted_at, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_type1_rows, :deleted_at, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_type1s, :active, if_exists: true
    remove_column :extractions_extraction_forms_projects_sections_type1s, :deleted_at, if_exists: true
    remove_column :eefpsqrcf_qrcqrcos, :active, if_exists: true
    remove_column :eefpsqrcf_qrcqrcos, :deleted_at, if_exists: true
    remove_column :followup_fields, :deleted_at, if_exists: true
    remove_column :frequencies, :deleted_at, if_exists: true
    remove_column :key_questions, :deleted_at, if_exists: true
    remove_column :key_questions_projects, :active, if_exists: true
    remove_column :key_questions_projects, :deleted_at, if_exists: true
    remove_column :key_questions_projects_questions, :active, if_exists: true
    remove_column :key_questions_projects_questions, :deleted_at, if_exists: true
    remove_column :keywords, :deleted_at, if_exists: true
    remove_column :labels, :deleted_at, if_exists: true
    remove_column :labels_reasons, :deleted_at, if_exists: true
    remove_column :measures, :deleted_at, if_exists: true
    remove_column :message_types, :deleted_at, if_exists: true
    remove_column :messages, :deleted_at, if_exists: true
    remove_column :notes, :deleted_at, if_exists: true
    remove_column :orderings, :active, if_exists: true
    remove_column :orderings, :deleted_at, if_exists: true
    remove_column :organizations, :deleted_at, if_exists: true
    remove_column :population_names, :deleted_at, if_exists: true
    remove_column :profiles, :deleted_at, if_exists: true
    remove_column :projects, :deleted_at, if_exists: true
    remove_column :projects_users, :active, if_exists: true
    remove_column :projects_users, :deleted_at, if_exists: true
    remove_column :projects_users_roles, :active, if_exists: true
    remove_column :projects_users_roles, :deleted_at, if_exists: true
    remove_column :projects_users_term_groups_colors, :deleted_at, if_exists: true
    remove_column :projects_users_term_groups_colors_terms, :deleted_at, if_exists: true
    remove_column :publishings, :active, if_exists: true
    remove_column :publishings, :deleted_at, if_exists: true
    remove_column :quality_dimension_options, :deleted_at, if_exists: true
    remove_column :quality_dimension_questions, :deleted_at, if_exists: true
    remove_column :quality_dimension_questions_quality_dimension_options, :active, if_exists: true
    remove_column :quality_dimension_questions_quality_dimension_options, :deleted_at, if_exists: true
    remove_column :quality_dimension_section_groups, :active, if_exists: true
    remove_column :quality_dimension_section_groups, :deleted_at, if_exists: true
    remove_column :quality_dimension_sections, :deleted_at, if_exists: true
    remove_column :question_row_column_fields, :deleted_at, if_exists: true
    remove_column :question_row_column_options, :deleted_at, if_exists: true
    remove_column :question_row_column_types, :deleted_at, if_exists: true
    remove_column :question_row_columns, :deleted_at, if_exists: true
    remove_column :question_row_columns_question_row_column_options, :active, if_exists: true
    remove_column :question_row_columns_question_row_column_options, :deleted_at, if_exists: true
    remove_column :question_rows, :deleted_at, if_exists: true
    remove_column :questions, :deleted_at, if_exists: true
    remove_column :reasons, :deleted_at, if_exists: true
    remove_column :records, :deleted_at, if_exists: true
    remove_column :result_statistic_section_types, :deleted_at, if_exists: true
    remove_column :result_statistic_section_types_measures, :active, if_exists: true
    remove_column :result_statistic_section_types_measures, :deleted_at, if_exists: true
    remove_index :result_statistic_sections, name: 'index_rss_on_rsst_id_eefpst1rc_id_uniq', if_exists: true
    remove_column :result_statistic_sections, :deleted_at, if_exists: true
    remove_column :result_statistic_sections_measures, :active, if_exists: true
    remove_column :result_statistic_sections_measures, :deleted_at, if_exists: true
    remove_column :roles, :deleted_at, if_exists: true
    remove_column :sections, :deleted_at, if_exists: true
    remove_column :suggestions, :active, if_exists: true
    remove_column :suggestions, :deleted_at, if_exists: true
    remove_column :tags, :deleted_at, if_exists: true
    remove_column :taggings, :deleted_at, if_exists: true
    remove_column :tasks, :deleted_at, if_exists: true
    remove_column :timepoint_names, :deleted_at, if_exists: true
    remove_column :tps_arms_rssms, :active, if_exists: true
    remove_column :tps_arms_rssms, :deleted_at, if_exists: true
    remove_column :tps_comparisons_rssms, :active, if_exists: true
    remove_column :tps_comparisons_rssms, :deleted_at, if_exists: true
    remove_column :type1s, :deleted_at, if_exists: true
    remove_column :users, :deleted_at, if_exists: true
    remove_column :wacs_bacs_rssms, :active, if_exists: true
    remove_column :wacs_bacs_rssms, :deleted_at, if_exists: true

    # STEP 4
    add_foreign_key "abstrackr_settings", "profiles", if_not_exists: true
    add_foreign_key "actions", "action_types", if_not_exists: true
    add_foreign_key "actions", "users", if_not_exists: true
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", if_not_exists: true
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", if_not_exists: true
    add_foreign_key "approvals", "users", if_not_exists: true
    add_foreign_key "assignments", "projects_users_roles", if_not_exists: true
    add_foreign_key "assignments", "tasks", if_not_exists: true
    add_foreign_key "assignments", "users", if_not_exists: true
    add_foreign_key "citations", "citation_types", if_not_exists: true
    add_foreign_key "citations_projects", "citations", if_not_exists: true
    add_foreign_key "citations_projects", "consensus_types", if_not_exists: true
    add_foreign_key "citations_projects", "projects", if_not_exists: true
    add_foreign_key "citations_tasks", "citations", if_not_exists: true
    add_foreign_key "citations_tasks", "tasks", if_not_exists: true
    add_foreign_key "colorings", "color_choices", if_not_exists: true
    add_foreign_key "comparate_groups", "comparisons", if_not_exists: true
    add_foreign_key "comparates", "comparable_elements", if_not_exists: true
    add_foreign_key "comparates", "comparate_groups", if_not_exists: true
    add_foreign_key "comparisons_arms_rssms", "comparisons", if_not_exists: true
    add_foreign_key "comparisons_arms_rssms", "extractions_extraction_forms_projects_sections_type1s", if_not_exists: true
    add_foreign_key "comparisons_arms_rssms", "result_statistic_sections_measures", if_not_exists: true
    add_foreign_key "comparisons_measures", "comparisons", if_not_exists: true
    add_foreign_key "comparisons_measures", "measures", if_not_exists: true
    add_foreign_key "comparisons_result_statistic_sections", "comparisons", if_not_exists: true
    add_foreign_key "comparisons_result_statistic_sections", "result_statistic_sections", if_not_exists: true
    add_foreign_key "degrees_profiles", "degrees", if_not_exists: true
    add_foreign_key "degrees_profiles", "profiles", if_not_exists: true
    add_foreign_key "dispatches", "users", if_not_exists: true
    add_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "eefps_qrcfs", "extractions_extraction_forms_projects_sections_type1s", if_not_exists: true
    add_foreign_key "eefps_qrcfs", "question_row_column_fields", if_not_exists: true
    add_foreign_key "eefpsqrcf_qrcqrcos", "eefps_qrcfs", if_not_exists: true
    add_foreign_key "eefpsqrcf_qrcqrcos", "question_row_columns_question_row_column_options", if_not_exists: true
    add_foreign_key "exported_files", "file_types", if_not_exists: true
    add_foreign_key "exported_files", "projects", if_not_exists: true
    add_foreign_key "exported_files", "users", if_not_exists: true
    add_foreign_key "exported_items", "export_types", if_not_exists: true
    add_foreign_key "extraction_forms_projects", "extraction_forms", if_not_exists: true
    add_foreign_key "extraction_forms_projects", "extraction_forms_project_types", if_not_exists: true
    add_foreign_key "extraction_forms_projects", "projects", if_not_exists: true
    add_foreign_key "extraction_forms_projects_section_options", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_section_types", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections", "sections", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections_type1s", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections_type1s", "type1_types", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections_type1s", "type1s", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "extraction_forms_projects_sections_type1s", if_not_exists: true
    add_foreign_key "extraction_forms_projects_sections_type1s_timepoint_names", "timepoint_names", if_not_exists: true
    add_foreign_key "extractions", "citations_projects", if_not_exists: true
    add_foreign_key "extractions", "projects", if_not_exists: true
    add_foreign_key "extractions", "projects_users_roles", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections", "extractions", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections", "extractions_extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "extractions_extraction_forms_projects_sections_type1_rows", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1_row_columns", "timepoint_names", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "extractions_extraction_forms_projects_sections_type1s", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1_rows", "population_names", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "extractions_extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1_types", if_not_exists: true
    add_foreign_key "extractions_extraction_forms_projects_sections_type1s", "type1s", if_not_exists: true
    add_foreign_key "funding_sources_sd_meta_data", "funding_sources", if_not_exists: true
    add_foreign_key "funding_sources_sd_meta_data", "sd_meta_data", if_not_exists: true
    add_foreign_key "imported_files", "file_types", if_not_exists: true
    add_foreign_key "imported_files", "sections", if_not_exists: true
    add_foreign_key "invitations", "roles", if_not_exists: true
    add_foreign_key "journals", "citations", if_not_exists: true
    add_foreign_key "key_questions_projects", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "key_questions_projects", "key_questions", if_not_exists: true
    add_foreign_key "key_questions_projects", "projects", if_not_exists: true
    add_foreign_key "key_questions_projects_questions", "key_questions_projects", if_not_exists: true
    add_foreign_key "key_questions_projects_questions", "questions", if_not_exists: true
    add_foreign_key "labels", "citations_projects", if_not_exists: true
    add_foreign_key "labels", "label_types", if_not_exists: true
    add_foreign_key "labels", "projects_users_roles", if_not_exists: true
    add_foreign_key "labels_reasons", "labels", if_not_exists: true
    add_foreign_key "labels_reasons", "projects_users_roles", if_not_exists: true
    add_foreign_key "labels_reasons", "reasons", if_not_exists: true
    add_foreign_key "measurements", "comparisons_measures", if_not_exists: true
    add_foreign_key "message_types", "frequencies", if_not_exists: true
    add_foreign_key "messages", "message_types", if_not_exists: true
    add_foreign_key "notes", "projects_users_roles", if_not_exists: true
    add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", if_not_exists: true
    add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", if_not_exists: true
    add_foreign_key "pending_invitations", "invitations", if_not_exists: true
    add_foreign_key "pending_invitations", "users", if_not_exists: true
    add_foreign_key "predictions", "citations_projects", if_not_exists: true
    add_foreign_key "priorities", "citations_projects", if_not_exists: true
    add_foreign_key "profiles", "organizations", if_not_exists: true
    add_foreign_key "profiles", "users", if_not_exists: true
    add_foreign_key "projects_users", "projects", if_not_exists: true
    add_foreign_key "projects_users", "users", if_not_exists: true
    add_foreign_key "projects_users_roles", "projects_users", if_not_exists: true
    add_foreign_key "projects_users_roles", "roles", if_not_exists: true
    add_foreign_key "projects_users_roles_teams", "projects_users_roles", if_not_exists: true
    add_foreign_key "projects_users_roles_teams", "teams", if_not_exists: true
    add_foreign_key "projects_users_term_groups_colors", "projects_users", if_not_exists: true
    add_foreign_key "projects_users_term_groups_colors", "term_groups_colors", if_not_exists: true
    add_foreign_key "projects_users_term_groups_colors_terms", "projects_users_term_groups_colors", if_not_exists: true
    add_foreign_key "projects_users_term_groups_colors_terms", "terms", if_not_exists: true
    add_foreign_key "publishings", "users", if_not_exists: true
    add_foreign_key "quality_dimension_questions", "quality_dimension_sections", if_not_exists: true
    add_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_options", if_not_exists: true
    add_foreign_key "quality_dimension_questions_quality_dimension_options", "quality_dimension_questions", if_not_exists: true
    add_foreign_key "question_row_column_fields", "question_row_columns", if_not_exists: true
    add_foreign_key "question_row_columns", "question_row_column_types", if_not_exists: true
    add_foreign_key "question_row_columns", "question_rows", if_not_exists: true
    add_foreign_key "question_row_columns_question_row_column_options", "question_row_column_options", if_not_exists: true
    add_foreign_key "question_row_columns_question_row_column_options", "question_row_columns", if_not_exists: true
    add_foreign_key "question_rows", "questions", if_not_exists: true
    add_foreign_key "questions", "extraction_forms_projects_sections", if_not_exists: true
    add_foreign_key "reasons", "label_types", if_not_exists: true
    add_foreign_key "result_statistic_section_types_measures", "measures", if_not_exists: true
    add_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types", if_not_exists: true
    add_foreign_key "result_statistic_section_types_measures", "result_statistic_section_types_measures", if_not_exists: true
    add_foreign_key "result_statistic_section_types_measures", "type1_types", if_not_exists: true
    add_foreign_key "result_statistic_sections", "extractions_extraction_forms_projects_sections_type1_rows", column: "population_id", if_not_exists: true
    add_foreign_key "result_statistic_sections", "result_statistic_section_types", if_not_exists: true
    add_foreign_key "result_statistic_sections_measures", "measures", if_not_exists: true
    add_foreign_key "result_statistic_sections_measures", "result_statistic_sections", if_not_exists: true
    add_foreign_key "result_statistic_sections_measures", "result_statistic_sections_measures", if_not_exists: true
    add_foreign_key "result_statistic_sections_measures_comparisons", "comparisons", if_not_exists: true
    add_foreign_key "result_statistic_sections_measures_comparisons", "result_statistic_sections", if_not_exists: true
    add_foreign_key "screening_options", "label_types", if_not_exists: true
    add_foreign_key "screening_options", "projects", if_not_exists: true
    add_foreign_key "screening_options", "screening_option_types", if_not_exists: true
    add_foreign_key "sd_analytic_frameworks", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_grey_literature_searches", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_journal_article_urls", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_key_questions", "key_questions", if_not_exists: true
    add_foreign_key "sd_key_questions", "sd_key_questions", if_not_exists: true
    add_foreign_key "sd_key_questions", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_key_questions_projects", "key_questions_projects", if_not_exists: true
    add_foreign_key "sd_key_questions_projects", "sd_key_questions", if_not_exists: true
    add_foreign_key "sd_key_questions_sd_picods", "sd_key_questions", if_not_exists: true
    add_foreign_key "sd_key_questions_sd_picods", "sd_picods", if_not_exists: true
    add_foreign_key "sd_meta_data", "review_types", if_not_exists: true
    add_foreign_key "sd_other_items", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_picods", "data_analysis_levels", if_not_exists: true
    add_foreign_key "sd_picods", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_picods_sd_picods_types", "sd_picods", if_not_exists: true
    add_foreign_key "sd_picods_sd_picods_types", "sd_picods_types", if_not_exists: true
    add_foreign_key "sd_prisma_flows", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_project_leads", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_project_leads", "users", if_not_exists: true
    add_foreign_key "sd_search_strategies", "sd_meta_data", if_not_exists: true
    add_foreign_key "sd_search_strategies", "sd_search_databases", if_not_exists: true
    add_foreign_key "sd_summary_of_evidences", "sd_key_questions", if_not_exists: true
    add_foreign_key "sd_summary_of_evidences", "sd_meta_data", if_not_exists: true
    add_foreign_key "statusings", "statuses", if_not_exists: true
    add_foreign_key "suggestions", "users", if_not_exists: true
    add_foreign_key "taggings", "projects_users_roles", if_not_exists: true
    add_foreign_key "taggings", "tags", if_not_exists: true
    add_foreign_key "tasks", "projects", if_not_exists: true
    add_foreign_key "tasks", "task_types", if_not_exists: true
    add_foreign_key "teams", "projects", if_not_exists: true
    add_foreign_key "teams", "team_types", if_not_exists: true
    add_foreign_key "term_groups_colors", "colors", if_not_exists: true
    add_foreign_key "term_groups_colors", "term_groups", if_not_exists: true
    add_foreign_key "tps_arms_rssms", "extractions_extraction_forms_projects_sections_type1s", if_not_exists: true
    add_foreign_key "tps_arms_rssms", "result_statistic_sections_measures", if_not_exists: true
    add_foreign_key "tps_comparisons_rssms", "comparisons", if_not_exists: true
    add_foreign_key "tps_comparisons_rssms", "result_statistic_sections_measures", if_not_exists: true
    add_foreign_key "users", "user_types", if_not_exists: true
    add_foreign_key "wacs_bacs_rssms", "result_statistic_sections_measures", if_not_exists: true
  end
end
