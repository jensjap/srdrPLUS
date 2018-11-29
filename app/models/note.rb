class Note < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_users_role
  belongs_to :notable, polymorphic: true

  delegate :project, to: :projects_users_role
end
