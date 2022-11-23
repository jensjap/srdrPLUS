class CreateAbstractScreeningsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_users do |t|
      t.references :abstract_screening, null: false, type: :bigint, index: { name: 'asu_on_as' }
      t.references :user, null: false, type: :bigint, index: { name: 'asu_on_u' }
      t.timestamps
    end
    add_index :abstract_screenings_users, %i[abstract_screening_id user_id],
              unique: true, name: 'u_id_on_as_id'
  end
end
