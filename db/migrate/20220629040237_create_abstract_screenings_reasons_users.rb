class CreateAbstractScreeningsReasonsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_reasons_users do |t|
      t.references :abstract_screening, index: { name: 'asru_on_as' }
      t.references :reason, index: { name: 'asru_on_r' }
      t.references :user, index: { name: 'asru_on_u' }
      t.timestamps
    end
    add_index :abstract_screenings_reasons_users,
              %i[abstract_screening_id reason_id user_id],
              unique: true,
              name: 'as_r_u'
  end
end
