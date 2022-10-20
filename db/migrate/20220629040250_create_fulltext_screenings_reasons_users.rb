class CreateFulltextScreeningsReasonsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_reasons_users do |t|
      t.references :fulltext_screening, index: { name: 'fsru_on_fs' }
      t.references :reason, index: { name: 'fsru_on_r' }
      t.references :user, index: { name: 'fsru_on_u' }
      t.timestamps
    end
    add_index :fulltext_screenings_reasons_users,
              %i[fulltext_screening_id reason_id user_id],
              unique: true,
              name: 'fs_r_u'
  end
end
