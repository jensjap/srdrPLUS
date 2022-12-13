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
  has_many :taggings, through: :projects_users_roles, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy

  has_many :sd_meta_data_queries, dependent: :destroy

  accepts_nested_attributes_for :imports, allow_destroy: true
  accepts_nested_attributes_for :imported_files, allow_destroy: true
end
