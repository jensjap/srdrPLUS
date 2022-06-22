class CreateAbstractScreeningsReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_reasons do |t|
      t.references :abstract_screening, null: false, type: :bigint, index: { name: 'asr_on_as' }
      t.references :reason, null: false, type: :bigint, index: { name: 'asr_on_r' }
      t.timestamps
    end
    add_index :abstract_screenings_reasons, %i[abstract_screening_id reason_id],
              unique: true, name: 'asr_as_on_r'
  end
end
