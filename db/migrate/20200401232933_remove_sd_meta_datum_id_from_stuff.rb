class RemoveSdMetaDatumIdFromStuff < ActiveRecord::Migration[5.2]
  def change
    change_table :sd_narrative_results do |t|
      t.remove :sd_meta_datum_id
    end

    change_table :sd_evidence_tables do |t|
      t.remove :sd_meta_datum_id
    end

    change_table :sd_pairwise_meta_analytic_results do |t|
      t.remove :sd_meta_datum_id
    end
    
    change_table :sd_meta_regression_analysis_results do |t|
      t.remove :sd_meta_datum_id
    end

    change_table :network_meta_analysis_results do |t|
      t.remove :sd_meta_datum_id
      t.remove :sd_key_question_id
      t.references :sd_result_item
    end
  end
end
