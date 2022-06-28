class WordWeight < ApplicationRecord
  belongs_to :abstract_screenings_projects_users_role
  delegate :abstract_screening, to: :abstract_screenings_projects_users_role
end
