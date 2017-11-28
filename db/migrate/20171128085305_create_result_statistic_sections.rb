class CreateResultStatisticSections < ActiveRecord::Migration[5.0]
  def change
    create_table :result_statistic_sections do |t|
      t.references :result_statistic_section_type, foreign_key: true, index: { name: 'index_rss_on_rsst_id' }
      t.references :subgroup
      t.datetime :deleted_at

      t.timestamps
    end

    add_foreign_key :result_statistic_sections, :extractions_extraction_forms_projects_sections_type1_row_columns, column: :subgroup_id
    add_index :result_statistic_sections, :deleted_at
    add_index :result_statistic_sections, [:result_statistic_section_type_id, :subgroup_id, :deleted_at], name: 'index_rss_on_rsst_id_eefpst1rc_id_uniq', where: 'deleted_at IS NULL', unique: true
  end
end
