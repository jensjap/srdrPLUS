class AddSdMetaDataToSdResultItems < ActiveRecord::Migration[5.2]
  def change
    change_table :sd_result_items do |t|
      t.references :sd_meta_datum
    end
  end
end
