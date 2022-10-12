class CreateFulltextScreeningsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_users do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'fsu_on_fs' }
      t.references :user, null: false, type: :bigint, index: { name: 'fsu_on_u' }
      t.timestamps
    end
    add_index :fulltext_screenings_users, %i[fulltext_screening_id user_id],
              unique: true, name: 'u_id_on_fs_id'
  end
end
