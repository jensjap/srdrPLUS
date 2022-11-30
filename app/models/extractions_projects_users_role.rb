# == Schema Information
#
# Table name: extractions_projects_users_roles
#
#  id                     :integer          not null, primary key
#  extraction_id          :integer
#  projects_users_role_id :integer
#  deleted_at             :datetime
#  active                 :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ExtractionsProjectsUsersRole < ApplicationRecord
  belongs_to :extraction,          inverse_of: :extractions_projects_users_roles
  belongs_to :projects_users_role, inverse_of: :extractions_projects_users_roles
end
