# == Schema Information
#
# Table name: reasons
#
#  id            :integer          not null, primary key
#  name          :string(1000)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  label_type_id :integer
#

class Reason < ApplicationRecord
  has_many :abstract_screening_results_reasons
  has_many :abstract_screening_results, through: :abstract_screening_results_reasons
  has_many :fulltext_screening_results_reasons
  has_many :fulltext_screening_results, through: :fulltext_screening_results_reasons

  include SharedQueryableMethods

  has_many :labels_reasons, inverse_of: :reason

  scope :by_projects_user, lambda { |projects_user|
                             joins(:labels_reasons).where(labels_reasons: { projects_users_role_id: projects_user.projects_users_roles }).order(:name).distinct
                           }

  scope :by_project_lead, lambda { |project|
                            joins(:labels_reasons).where(labels_reasons: { projects_users_role_id: project.projects_users_roles.where(role: Role.find_by(name: 'Leader')) }).order(:name).distinct
                          }
end
