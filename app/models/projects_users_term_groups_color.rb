class ProjectsUsersTermGroupsColor < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_user
  belongs_to :term_groups_color

  has_many :projects_users_term_groups_colors_terms
  has_many :terms, through: :projects_users_term_groups_colors_terms
end
