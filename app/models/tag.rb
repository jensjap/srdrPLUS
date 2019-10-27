# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Tag < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include SharedQueryableMethods

  has_many :taggings

  scope :by_project_lead, -> ( project ) { joins( :taggings ).where( taggings: { projects_users_role_id: project.projects_users_roles.where( role: Role.find_by( name: 'Leader' ) ) } ).order( :name ).distinct }

  scope :by_user, -> ( user ) { joins( :taggings ).where( taggings: { projects_users_role_id: user.projects_users_roles } ).order( :name ).distinct }

  scope :by_projects_user, -> ( projects_user ) { joins( :taggings ).where( taggings: { projects_users_role_id: projects_user.projects_users_roles } ).order( :name ).distinct }
end
