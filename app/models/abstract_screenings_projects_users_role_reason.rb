# == Schema Information
#
# Table name: abstract_screenings_projects_users_role_reasons
#
#  id                                         :bigint           not null, primary key
#  abstract_screenings_projects_users_role_id :bigint
#  reason_id                                  :bigint
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class AbstractScreeningsProjectsUsersRoleReason < ApplicationRecord
  belongs_to :abstract_screenings_projects_users_role
  belongs_to :reason
end
