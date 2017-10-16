class ProjectsUsersRole < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :projects_user, inverse_of: :projects_users_roles
  belongs_to :role, inverse_of: :projects_users_roles
end
