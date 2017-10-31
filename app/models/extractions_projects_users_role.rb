class ExtractionsProjectsUsersRole < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction,          inverse_of: :extractions_projects_users_roles
  belongs_to :projects_users_role, inverse_of: :extractions_projects_users_roles
end
