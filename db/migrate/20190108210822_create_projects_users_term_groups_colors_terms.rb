class CreateProjectsUsersTermGroupsColorsTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_users_term_groups_colors_terms do |t|
      t.references :projects_users_term_groups_color, foreign_key: true, index: { name: 'index_putgcp_on_putc_id' }

      t.references :term, foreign_key: true, index: { name: 'index_putgcp_on_terms_id' }
      t.datetime :deleted_at, index: true
    end
  end
end
