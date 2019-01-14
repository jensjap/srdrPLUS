class ProjectsUsersTermGroupsColorsTerm< ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_users_term_groups_color
  belongs_to :term

