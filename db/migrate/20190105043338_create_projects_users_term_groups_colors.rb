class CreateProjectsUsersTermGroupsColors < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_users_term_groups_colors do |t|
      t.references :term_groups_color, foreign_key: true
      t.references :projects_user, foreign_key: true
      t.datetime :deleted_at, index: true
    end
  end
end
