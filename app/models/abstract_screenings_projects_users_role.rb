class AbstractScreeningsProjectsUsersRole < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :projects_users_role
end
