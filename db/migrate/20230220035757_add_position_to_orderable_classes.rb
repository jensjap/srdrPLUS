class AddPositionToOrderableClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :authors_citations, :position, :integer, default: 999_999
    add_column :extraction_forms_projects_sections, :position, :integer, default: 999_999
    add_column :extraction_forms_projects_sections_type1s, :position, :integer, default: 999_999
    add_column :extractions_extraction_forms_projects_sections_type1s, :position, :integer, default: 999_999
    add_column :key_questions_projects, :position, :integer, default: 999_999
    add_column :questions, :position, :integer, default: 999_999
    add_column :result_statistic_sections_measures, :position, :integer, default: 999_999
    add_column :sd_analytic_frameworks, :position, :integer, default: 999_999
    add_column :sd_evidence_tables, :position, :integer, default: 999_999
    add_column :sd_grey_literature_searches, :position, :integer, default: 999_999
    add_column :sd_journal_article_urls, :position, :integer, default: 999_999
    add_column :sd_key_questions, :position, :integer, default: 999_999
    add_column :sd_key_questions_sd_picods, :position, :integer, default: 999_999
    add_column :sd_meta_regression_analysis_results, :position, :integer, default: 999_999
    add_column :sd_narrative_results, :position, :integer, default: 999_999
    add_column :sd_network_meta_analysis_results, :position, :integer, default: 999_999
    add_column :sd_other_items, :position, :integer, default: 999_999
    add_column :sd_pairwise_meta_analytic_results, :position, :integer, default: 999_999
    add_column :sd_picods, :position, :integer, default: 999_999
    add_column :sd_prisma_flows, :position, :integer, default: 999_999
    add_column :sd_result_items, :position, :integer, default: 999_999
    add_column :sd_search_strategies, :position, :integer, default: 999_999
    add_column :sd_summary_of_evidences, :position, :integer, default: 999_999

    add_index :authors_citations, :position
    add_index :extraction_forms_projects_sections, :position
    add_index :extraction_forms_projects_sections_type1s, :position
    add_index :extractions_extraction_forms_projects_sections_type1s, :position, name: 'eefpst1_id'
    add_index :key_questions_projects, :position
    add_index :questions, :position
    add_index :result_statistic_sections_measures, :position
    add_index :sd_analytic_frameworks, :position
    add_index :sd_evidence_tables, :position
    add_index :sd_grey_literature_searches, :position
    add_index :sd_journal_article_urls, :position
    add_index :sd_key_questions, :position
    add_index :sd_key_questions_sd_picods, :position
    add_index :sd_meta_regression_analysis_results, :position
    add_index :sd_narrative_results, :position
    add_index :sd_network_meta_analysis_results, :position
    add_index :sd_other_items, :position
    add_index :sd_pairwise_meta_analytic_results, :position
    add_index :sd_picods, :position
    add_index :sd_prisma_flows, :position
    add_index :sd_result_items, :position
    add_index :sd_search_strategies, :position
    add_index :sd_summary_of_evidences, :position
  end
end
