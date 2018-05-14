class CreateResultStatisticSectionTypesMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :result_statistic_section_types_measures do |t|
      t.references :result_statistic_section_type, foreign_key: true, index: { name: 'index_rsstm_on_rsst_id' }
      t.references :measure,                       foreign_key: true, index: { name: 'index_rsstm_on_m_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :result_statistic_section_types_measures, :deleted_at
    add_index :result_statistic_section_types_measures, :active
  end
end
