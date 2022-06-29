class CreateAbstractScreeningsProjectsUsersRoleReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_projects_users_role_reasons do |t|
      t.references :abstract_screenings_projects_users_role, index: { name: 'aspurr_on_aspur' }
      t.references :reason, index: { name: 'aspurr_on_r' }
      t.timestamps
    end
  end
end
