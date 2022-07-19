# == Schema Information
#
# Table name: fulltext_screening_results
#
#  id                                         :bigint           not null, primary key
#  fulltext_screening_id                      :bigint
#  fulltext_screenings_projects_users_role_id :bigint
#  fulltext_screenings_citations_project_id   :bigint
#  label                                      :integer
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class FulltextScreeningResult < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :fulltext_screenings_citations_project
  belongs_to :fulltext_screenings_projects_users_role

  has_one :citations_project, through: :fulltext_screenings_citations_project
  has_one :citation, through: :citations_project
  has_one :projects_users_role, through: :fulltext_screenings_projects_users_role
  has_one :projects_user, through: :projects_users_role
  has_one :user, through: :projects_user

  has_many :fulltext_screening_results_reasons
  has_many :reasons, through: :fulltext_screening_results_reasons
  has_many :fulltext_screening_results_tags
  has_many :tags, through: :fulltext_screening_results_tags

  has_one :note, as: :notable

  def self.users_previous_asr_id(asr_id, fulltext_screenings_projects_users_role)
    where(fulltext_screenings_projects_users_role:)
      .where('updated_at < ?', AbstractScreeningResult.find(asr_id).updated_at)
      .where('label IS NOT NULL')
      .order(updated_at: :desc)
      .limit(1)&.first&.id
  end

  def self.find_unfinished_fulltext_screening_result(fulltext_screening, fulltext_screenings_projects_users_role)
    where(fulltext_screening:)
      .where(fulltext_screenings_projects_users_role:)
      .where('label IS NULL')
      .first
  end

  def process_payload(payload, aspur)
    update(label: payload[:label_value]) if payload[:label_value]
    aspur.process_reasons(self, payload[:predefined_reasons], payload[:custom_reasons])
    aspur.process_tags(self, payload[:predefined_tags], payload[:custom_tags])
    self&.note&.really_destroy!
    create_note!(
      value: payload[:notes],
      projects_users_role: aspur.projects_users_role
    )
    fulltext_screening.evaluate_transition(self)
  end

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
