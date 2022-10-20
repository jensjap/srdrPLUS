class CreateFulltextScreeningsReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_reasons do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'fsr_on_fs' }
      t.references :reason, null: false, type: :bigint, index: { name: 'fsr_on_r' }
      t.timestamps
    end
    add_index :fulltext_screenings_reasons, %i[fulltext_screening_id reason_id],
              unique: true, name: 'fsr_fs_on_r'
  end
end
