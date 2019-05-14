class CreateSdSummaryOfEvidences < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_summary_of_evidences do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.references :sd_key_question, foreign_key: true
      t.text :name
      t.string :soe_type

      t.timestamps
    end
  end
end
