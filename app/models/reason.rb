class Reason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :labels_reasons
  belongs_to :label_type

  scope :by_projects_user, -> ( projects_user ) { where( projects_users_role_id: projects_user.projects_users_roles ).order( :name ).uniq }

  scope :by_project_lead, -> ( project ) { where( projects_users_role_id: project.projects_users_roles.where( role: Role.find_by( name: 'Leader' ) ) ).order( :name ).uniq }
end
