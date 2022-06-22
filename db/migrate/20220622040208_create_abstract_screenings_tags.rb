class CreateAbstractScreeningsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_tags do |t|
      t.references :abstract_screening, null: false, type: :bigint, index: { name: 'ast_on_as' }
      t.references :tag, null: false, type: :bigint, index: { name: 'ast_on_t' }
      t.timestamps
    end
    add_index :abstract_screenings_tags, %i[abstract_screening_id tag_id],
              unique: true, name: 'ast_as_on_t'
  end
end
