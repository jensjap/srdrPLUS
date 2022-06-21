class CreateJoinTableProjectsUsersRolesAbstractScreenings < ActiveRecord::Migration[7.0]
  def change
    create_join_table :projects_users_roles, :abstract_screenings do |t|
      t.index %i[projects_users_role_id abstract_screening_id], unique: true, name: 'pur_id_on_as_id'
      t.index :abstract_screening_id, name: 'puras_id_on_as_id'
    end
  end
end
