class CreateAbstractScreeningsProjectsUsersRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_projects_users_roles do |t|
      t.references :abstract_screening, null: false, type: :bigint, index: { name: 'aspur_on_as' }
      t.references :projects_users_role, null: false, type: :bigint, index: { name: 'aspur_on_pur' }
      t.timestamps
    end
    add_index :abstract_screenings_projects_users_roles, %i[abstract_screening_id projects_users_role_id],
              unique: true, name: 'pur_id_on_as_id'
  end
end
