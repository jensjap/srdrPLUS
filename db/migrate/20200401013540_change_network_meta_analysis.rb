class ChangeNetworkMetaAnalysis < ActiveRecord::Migration[5.2]
  def change
    change_table :network_meta_analysis_results do |t|
      t.references :sd_key_question
    end
    change_table :sd_pairwise_meta_analytic_results do |t|
      t.remove :outcome_name
    end
    change_table :sd_meta_regression_analysis_results do |t|
      t.remove :outcome_name
    end
    change_table :sd_evidence_tables do |t|
      t.remove :outcome_name
    end
  end
end
