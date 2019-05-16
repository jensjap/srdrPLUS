class AddReportAccessionIdToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :report_accession_id, :string
  end
end
