# == Schema Information
#
# Table name: fulltext_screenings_projects_users_role_reasons
#
#  id                                         :bigint           not null, primary key
#  fulltext_screenings_projects_users_role_id :bigint
#  reason_id                                  :bigint
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class FulltextScreeningsProjectsUsersRoleReason < ApplicationRecord
  belongs_to :fulltext_screenings_projects_users_role
  belongs_to :reason
end
