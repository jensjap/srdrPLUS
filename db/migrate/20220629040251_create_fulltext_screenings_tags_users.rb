class CreateFulltextScreeningsTagsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_tags_users do |t|
      t.references :fulltext_screening, index: { name: 'fstu_on_fs' }
      t.references :tag, index: { name: 'fstu_on_t' }
      t.references :user, index: { name: 'fstu_on_u' }
      t.timestamps
    end
    add_index :fulltext_screenings_tags_users,
              %i[fulltext_screening_id tag_id user_id],
              unique: true,
              name: 'fs_t_u'
  end
end
