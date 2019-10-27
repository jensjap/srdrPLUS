class CreateFundingSourcesSdMetaData < ActiveRecord::Migration[5.0]
  def change
    create_table :funding_sources_sd_meta_data do |t|
      t.references :funding_source, foreign_key: true
      t.references :sd_meta_datum, foreign_key: true

      t.timestamps
    end
  end
end
