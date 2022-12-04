# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ApplicationRecord
  LEADER       = 'Leader'.freeze
  CONSOLIDATOR = 'Consolidator'.freeze
  CONTRIBUTOR  = 'Contributor'.freeze
  AUDITOR      = 'Auditor'.freeze

  has_many :projects_users_roles, dependent: :destroy, inverse_of: :role
  has_many :projects_users, through: :projects_users_roles, dependent: :destroy

  has_many :invitations, as: :invitable, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
