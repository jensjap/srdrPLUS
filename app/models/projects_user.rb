# == Schema Information
#
# Table name: projects_users
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  deleted_at :datetime
#  active     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectsUser < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :project, inverse_of: :projects_users
  belongs_to :user, inverse_of: :projects_users

  has_many :projects_users_roles, dependent: :destroy, inverse_of: :projects_user
  has_many :roles, through: :projects_users_roles, dependent: :destroy
  has_many :assignments, through: :projects_users_roles, dependent: :destroy
  has_many :exported_items, dependent: :destroy
  has_many :imported_files, dependent: :destroy
  has_many :taggings, through: :projects_users_roles, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy

  has_many :projects_users_term_groups_colors, dependent: :destroy
  has_many :projects_users_term_groups_colors_terms, through: :projects_users_term_groups_colors, dependent: :destroy
  has_many :terms, through: :projects_users_term_groups_colors_terms, dependent: :destroy
  has_many :term_groups_colors, through: :projects_users_term_groups_colors, dependent: :destroy

  accepts_nested_attributes_for :imported_files, allow_destroy: true
end
