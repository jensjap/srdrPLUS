class CreateSdResultItems < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_result_items do |t|
      t.references :sd_key_question
      t.timestamps
    end
    change_table :sd_narrative_results do |t|
      t.references :sd_result_item
      t.remove :sd_key_question_id
    end

    change_table :sd_evidence_tables do |t|
      t.references :sd_result_item
      t.remove :sd_key_question_id
    end

    change_table :sd_pairwise_meta_analytic_results do |t|
      t.references :sd_result_item
      t.remove :sd_key_question_id
    end
    
    change_table :sd_meta_regression_analysis_results do |t|
      t.references :sd_result_item
      t.remove :sd_key_question_id
    end
  end
end
