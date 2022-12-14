# == Schema Information
#
# Table name: projects_users
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectsUser < ApplicationRecord
  ROLES = %w[Leader Consolidator Contributor Auditor].freeze

  belongs_to :project, inverse_of: :projects_users # , touch: true
  belongs_to :user, inverse_of: :projects_users

  has_many :imports, dependent: :destroy
  has_many :imported_files, through: :imports

  has_many :sd_meta_data_queries, dependent: :destroy

  accepts_nested_attributes_for :imports, allow_destroy: true
  accepts_nested_attributes_for :imported_files, allow_destroy: true

  def make_leader!
    return if project_leader?

    update!(permissions: permissions + 1)
  end

  def project_leader?
    permissions.to_s(2)[-1] == '1'
  end

  def project_consolidator?
    project_leader? || permissions.to_s(2)[-2] == '1'
  end

  def project_contributor?
    project_leader? || project_consolidator? || permissions.to_s(2)[-3] == '1'
  end

  def project_auditor?
    project_leader? || project_consolidator? || project_contributor? || permissions.to_s(2)[-4] == '1'
  end
end
