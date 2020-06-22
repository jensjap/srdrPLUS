# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  team_type_id :integer
#  project_id   :integer
#  enabled      :boolean
#  name         :string(255)
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Team < ApplicationRecord
  include SharedInvitableMethods

  belongs_to :team_type
  belongs_to :project

  has_one :coloring, as: :colorable

  has_many :projects_users_roles_teams
  has_many :projects_users_roles, through: :projects_users_roles_teams, dependent: :destroy

  accepts_nested_attributes_for :projects_users_roles_teams, allow_destroy: true
end
