class RemoveExtraIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :suggestions, name: 'index_suggestions_on_suggestable_type_and_suggestable_id', if_exists: true
    remove_index :approvals, name: 'index_approvals_on_approvable_type_and_approvable_id', if_exists: true
    remove_index :comparisons_result_statistic_sections, name: 'index_crss_on_c_id', if_exists: true
    remove_index :degrees_profiles, name: 'index_degrees_profiles_on_degree_id', if_exists: true
    remove_index :dependencies, name: 'index_dependencies_on_dtype_did', if_exists: true
    remove_index :eefps_qrcfs, name: 'index_eefpsqrcf_on_eefpst1_id', if_exists: true
    remove_index :eefpsqrcf_qrcqrcos, name: 'index_eefpsqrcfqrcqrco_on_eefps_qrcf_id', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_efpt_id', if_exists: true
    remove_index :extraction_forms_projects, name: 'index_efp_on_ef_id', if_exists: true
    remove_index :extraction_forms_projects_section_options, name: 'index_efpso_on_efps_id', if_exists: true
    remove_index :extraction_forms_projects_sections, name: 'index_efps_on_efp_id', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s, name: 'index_efpst1_on_efps_id', if_exists: true
    remove_index :extraction_forms_projects_sections_type1s_timepoint_names, name: 'index_efpst1tn_on_efpst1_id',
                                                                             if_exists: true
    remove_index :extractions, name: 'index_extractions_on_project_id', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections, name: 'index_eefps_on_e_id', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_followup_fields,
                 name: 'index_eefpsff_followup_fields_on_extraction_id', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_row_columns,
                 name: 'index_eefpst1rc_on_eefpst1r_id', if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1_rows, name: 'index_eefpst1r_on_eefpst1_id',
                                                                             if_exists: true
    remove_index :extractions_extraction_forms_projects_sections_type1s, name: 'index_eefpst1_on_t1t_id',
                                                                         if_exists: true
    remove_index :extractions_projects_users_roles, name: 'index_epur_on_e_id', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_efps_id', if_exists: true
    remove_index :key_questions_projects, name: 'index_kqp_on_kq_id', if_exists: true
    remove_index :orderings, name: 'index_orderings_on_orderable_type_and_orderable_id', if_exists: true
    remove_index :projects_users, name: 'index_projects_users_on_project_id', if_exists: true
    remove_index :projects_users_roles, name: 'index_projects_users_roles_on_projects_user_id', if_exists: true
    remove_index :publishings, name: 'index_publishings_on_publishable_type_and_publishable_id', if_exists: true
    remove_index :quality_dimension_questions_quality_dimension_options, name: 'index_qdqqdo_on_qdq_id', if_exists: true
    remove_index :question_row_column_fields, name: 'index_qrcf_on_qrc_id', if_exists: true
    remove_index :question_row_columns, name: 'index_question_row_columns_on_question_row_id', if_exists: true
    remove_index :question_row_columns_question_row_column_options, name: 'index_qrcqrco_on_qrc_id', if_exists: true
    remove_index :question_rows, name: 'index_question_rows_on_question_id', if_exists: true
    remove_index :questions, name: 'index_questions_on_extraction_forms_projects_section_id', if_exists: true
    remove_index :result_statistic_sections, name: 'index_rss_on_rsst_id', if_exists: true
    remove_index :result_statistic_sections_measures, name: 'index_result_statistic_sections_measures_on_measure_id',
                                                      if_exists: true
    remove_index :sd_key_questions_key_question_types, name: 'index_sd_kqs', if_exists: true
    remove_index :statusings, name: 'index_statusings_on_statusable_type_and_statusable_id', if_exists: true
  end
end
