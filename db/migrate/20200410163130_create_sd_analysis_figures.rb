class CreateSdAnalysisFigures < ActiveRecord::Migration[5.2]
  def change
    change_table :sd_pairwise_meta_analytic_results do |t|
      t.remove :p_type
    end

    change_table :sd_network_meta_analysis_results do |t|
      t.remove :p_type
    end

    create_table :sd_analysis_figures do |t|
      t.bigint :sd_figurable_id
      t.string :sd_figurable_type
      t.string :p_type
      t.index [:sd_figurable_id, :sd_figurable_type], name:"index_sd_analysis_figures_on_type_id"
    end
  end
end
