class CreateAbstractScreeningsProjectsUsersRoleTags < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_projects_users_role_tags do |t|
      t.references :abstract_screenings_projects_users_role, index: { name: 'aspurt_on_aspur' }
      t.references :tag, index: { name: 'aspurt_on_r' }
      t.timestamps
    end
  end
end
