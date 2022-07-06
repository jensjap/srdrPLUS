# == Schema Information
#
# Table name: abstract_screenings_projects_users_role_tags
#
#  id                                         :bigint           not null, primary key
#  abstract_screenings_projects_users_role_id :bigint
#  tag_id                                     :bigint
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class AbstractScreeningsProjectsUsersRoleTag < ApplicationRecord
  belongs_to :abstract_screenings_projects_users_role
  belongs_to :tag
end
