class Reason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include SharedQueryableMethods

  has_many :labels_reasons, inverse_of: :reason

  scope :by_projects_user, -> ( projects_user ) { joins( :labels_reasons ).where( labels_reasons: { projects_users_role_id: projects_user.projects_users_roles } ).order( :name ).distinct }

  scope :by_project_lead, -> ( project ) { joins( :labels_reasons ).where( labels_reasons: { projects_users_role_id: project.projects_users_roles.where( role: Role.find_by( name: 'Leader' ) ) } ).order( :name ).distinct }
end
