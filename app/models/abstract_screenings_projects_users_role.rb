# == Schema Information
#
# Table name: abstract_screenings_projects_users_roles
#
#  id                     :bigint           not null, primary key
#  abstract_screening_id  :bigint           not null
#  projects_users_role_id :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class AbstractScreeningsProjectsUsersRole < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :projects_users_role
end
