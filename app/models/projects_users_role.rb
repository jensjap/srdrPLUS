# == Schema Information
#
# Table name: projects_users_roles
#
#  id               :integer          not null, primary key
#  projects_user_id :integer
#  role_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ProjectsUsersRole < ApplicationRecord
  belongs_to :projects_user
  belongs_to :role
end
