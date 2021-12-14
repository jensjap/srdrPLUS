class AddPctExtractionsWithUnstructuredDataToDataAudits < ActiveRecord::Migration[5.0]
  def change
    add_column :data_audits, :pct_extractions_with_unstructured_data, :string
  end
end
