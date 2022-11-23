class CreateAbstractScreeningsTagsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_tags_users do |t|
      t.references :abstract_screening, index: { name: 'astu_on_as' }
      t.references :tag, index: { name: 'astu_on_t' }
      t.references :user, index: { name: 'astu_on_u' }
      t.timestamps
    end
    add_index :abstract_screenings_tags_users,
              %i[abstract_screening_id tag_id user_id],
              unique: true,
              name: 'as_t_u'
  end
end
