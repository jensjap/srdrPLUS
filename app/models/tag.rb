class Tag < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include SharedQueryableMethods
  include SharedProcessTokenMethods

  has_many :taggings

  scope :by_project_lead, -> ( project ) { joins( :taggings ).where( taggings: { projects_users_role_id: project.projects_users_roles.where( role: Role.find_by( name: 'Leader' ) ) } ).order( :name ).distinct }

  scope :by_user, -> ( user ) { joins( :taggings ).where( taggings: { projects_users_role_id: user.projects_users_roles } ).order( :name ).distinct }

  scope :by_projects_user, -> ( projects_user ) { joins( :taggings ).where( taggings: { projects_users_role_id: projects_user.projects_users_roles } ).order( :name ).distinct }
end
