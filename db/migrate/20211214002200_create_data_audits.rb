class CreateDataAudits < ActiveRecord::Migration[5.0]
  def change
    create_table :data_audits do |t|
      t.boolean :epc_source
      t.string  :epc_name
      t.string  :non_epc_name
      t.string  :capture_method
      t.string  :distiller_w_results
      t.string  :single_multiple_w_consolidation
      t.text    :notes

      t.timestamps
    end
  end
end
