class RenamePositionToPos < ActiveRecord::Migration[7.0]
  def change
    rename_column :abstract_screenings_reasons, :position, :pos
    rename_column :abstract_screenings_reasons_users, :position, :pos
    rename_column :abstract_screenings_tags, :position, :pos
    rename_column :abstract_screenings_tags_users, :position, :pos
    rename_column :extraction_forms_projects_sections, :position, :pos
    rename_column :extraction_forms_projects_sections_type1s, :position, :pos
    rename_column :extractions_extraction_forms_projects_sections_type1s, :position, :pos
    rename_column :fulltext_screenings_reasons, :position, :pos
    rename_column :fulltext_screenings_reasons_users, :position, :pos
    rename_column :fulltext_screenings_tags, :position, :pos
    rename_column :fulltext_screenings_tags_users, :position, :pos
    rename_column :key_questions_projects, :position, :pos
    rename_column :questions, :position, :pos
    rename_column :result_statistic_sections_measures, :position, :pos
    rename_column :sd_analytic_frameworks, :position, :pos
    rename_column :sd_evidence_tables, :position, :pos
    rename_column :sd_grey_literature_searches, :position, :pos
    rename_column :sd_journal_article_urls, :position, :pos
    rename_column :sd_key_questions, :position, :pos
    rename_column :sd_key_questions_sd_picods, :position, :pos
    rename_column :sd_meta_regression_analysis_results, :position, :pos
    rename_column :sd_narrative_results, :position, :pos
    rename_column :sd_network_meta_analysis_results, :position, :pos
    rename_column :sd_other_items, :position, :pos
    rename_column :sd_pairwise_meta_analytic_results, :position, :pos
    rename_column :sd_picods, :position, :pos
    rename_column :sd_prisma_flows, :position, :pos
    rename_column :sd_result_items, :position, :pos
    rename_column :sd_search_strategies, :position, :pos
    rename_column :sd_summary_of_evidences, :position, :pos
    rename_column :sf_columns, :position, :pos
    rename_column :sf_options, :position, :pos
    rename_column :sf_questions, :position, :pos
    rename_column :sf_rows, :position, :pos
    change_column_default :abstract_screenings_reasons, :pos, 999_999
    change_column_default :abstract_screenings_reasons_users, :pos, 999_999
    change_column_default :abstract_screenings_tags, :pos, 999_999
    change_column_default :abstract_screenings_tags_users, :pos, 999_999
    change_column_default :extraction_forms_projects_sections, :pos, 999_999
    change_column_default :extraction_forms_projects_sections_type1s, :pos, 999_999
    change_column_default :extractions_extraction_forms_projects_sections_type1s, :pos, 999_999
    change_column_default :fulltext_screenings_reasons, :pos, 999_999
    change_column_default :fulltext_screenings_reasons_users, :pos, 999_999
    change_column_default :fulltext_screenings_tags, :pos, 999_999
    change_column_default :fulltext_screenings_tags_users, :pos, 999_999
    change_column_default :key_questions_projects, :pos, 999_999
    change_column_default :questions, :pos, 999_999
    change_column_default :result_statistic_sections_measures, :pos, 999_999
    change_column_default :sd_analytic_frameworks, :pos, 999_999
    change_column_default :sd_evidence_tables, :pos, 999_999
    change_column_default :sd_grey_literature_searches, :pos, 999_999
    change_column_default :sd_journal_article_urls, :pos, 999_999
    change_column_default :sd_key_questions, :pos, 999_999
    change_column_default :sd_key_questions_sd_picods, :pos, 999_999
    change_column_default :sd_meta_regression_analysis_results, :pos, 999_999
    change_column_default :sd_narrative_results, :pos, 999_999
    change_column_default :sd_network_meta_analysis_results, :pos, 999_999
    change_column_default :sd_other_items, :pos, 999_999
    change_column_default :sd_pairwise_meta_analytic_results, :pos, 999_999
    change_column_default :sd_picods, :pos, 999_999
    change_column_default :sd_prisma_flows, :pos, 999_999
    change_column_default :sd_result_items, :pos, 999_999
    change_column_default :sd_search_strategies, :pos, 999_999
    change_column_default :sd_summary_of_evidences, :pos, 999_999
    change_column_default :sf_columns, :pos, 999_999
    change_column_default :sf_options, :pos, 999_999
    change_column_default :sf_questions, :pos, 999_999
    change_column_default :sf_rows, :pos, 999_999
  end
end