class CreateFulltextScreeningsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_tags do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'ftst_on_fts' }
      t.references :tag, null: false, type: :bigint, index: { name: 'ftst_on_t' }
      t.timestamps
    end
    add_index :fulltext_screenings_tags, %i[fulltext_screening_id tag_id],
              unique: true, name: 'ftst_as_on_t'
  end
end
