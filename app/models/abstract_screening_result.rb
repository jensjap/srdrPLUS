# == Schema Information
#
# Table name: abstract_screening_results
#
#  id                     :bigint           not null, primary key
#  projects_users_role_id :bigint
#  abstract_screening_id  :bigint
#  citations_project_id   :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class AbstractScreeningResult < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :abstract_screenings_citations_project
  belongs_to :abstract_screenings_projects_users_role

  has_one :citations_project, through: :abstract_screenings_citations_project
  has_one :citation, through: :citations_project
  has_one :projects_users_role, through: :abstract_screenings_projects_users_role
  has_one :projects_user, through: :projects_users_role
  has_one :user, through: :projects_user

  has_many :abstract_screening_results_reasons
  has_many :reasons, through: :abstract_screening_results_reasons
  has_many :abstract_screening_results_tags
  has_many :tags, through: :abstract_screening_results_tags

  has_many :notes, as: :notable

  def readable_label
    case label
    when -1
      'No'
    when 0
      'Maybe'
    when 1
      'Yes'
    end
  end
end
