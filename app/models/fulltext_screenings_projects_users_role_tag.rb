# == Schema Information
#
# Table name: fulltext_screenings_projects_users_role_tags
#
#  id                                         :bigint           not null, primary key
#  fulltext_screenings_projects_users_role_id :bigint
#  tag_id                                     :bigint
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class FulltextScreeningsProjectsUsersRoleTag < ApplicationRecord
  belongs_to :fulltext_screenings_projects_users_role
  belongs_to :tag
end
