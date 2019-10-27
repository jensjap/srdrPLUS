class CreateSdPicodsSdPicodsTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_picods_sd_picods_types do |t|
      t.references :sd_picod,       type: :integer, foreign_key: true, index: { name: "index_sdspt_sd_picod" }
      t.references :sd_picods_type, type: :integer, foreign_key: true, index: { name: "index_sdspt_sd_picod_type" }

      t.timestamps
    end
  end
end
