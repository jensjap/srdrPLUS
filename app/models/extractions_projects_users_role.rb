class ExtractionsProjectsUsersRole < ApplicationRecord
  belongs_to :extraction
  belongs_to :projects_users_role
end
