class Role < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :projects_users_roles, dependent: :destroy, inverse_of: :role
  has_many :projects_users, through: :projects_users_roles, dependent: :destroy

  has_many :invitations

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
