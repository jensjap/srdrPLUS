# == Schema Information
#
# Table name: projects_users
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  permissions :integer          default(0), not null
#  is_expert   :boolean          default(FALSE)
#

class ProjectsUser < ApplicationRecord
  ROLES = %w[Leader Consolidator Contributor Auditor].freeze

  belongs_to :project, inverse_of: :projects_users # , touch: true
  belongs_to :user, inverse_of: :projects_users

  has_many :projects_users_roles, dependent: :nullify

  has_many :imports, dependent: :destroy
  has_many :imported_files, through: :imports

  has_many :sd_meta_data_queries, dependent: :destroy

  accepts_nested_attributes_for :imports, allow_destroy: true
  accepts_nested_attributes_for :imported_files, allow_destroy: true

  validates :user_id, uniqueness: {
    scope: :project_id,
    message: 'must be unique. A user you are attempting to add to this project is already a member.' }

  def highest_role_string
    if project_leader?
      'Leader'
    elsif project_consolidator?
      'Consolidator'
    elsif project_contributor?
      'Contributor'
    elsif project_auditor?
      'Auditor'
    end
  end

  def roles_string
    roles = []
    roles << 'Leader' if project_leader?
    roles << 'Consolidator' if project_consolidator?
    roles << 'Contributor' if project_contributor?
    roles << 'Auditor' if project_auditor?
    roles.join(', ')
  end

  def make_leader!
    return if project_leader?

    update!(permissions: permissions + 1)
  end

  def make_consolidator!
    return if project_consolidator?

    update!(permissions: permissions + 2)
  end

  def make_contributor!
    return if project_contributor?

    update!(permissions: permissions + 4)
  end

  def make_auditor!
    return if project_auditor?

    update!(permissions: permissions + 8)
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
