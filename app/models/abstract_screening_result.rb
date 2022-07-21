# == Schema Information
#
# Table name: abstract_screening_results
#
#  id                                         :bigint           not null, primary key
#  abstract_screening_id                      :bigint
#  abstract_screenings_projects_users_role_id :bigint
#  abstract_screenings_citations_project_id   :bigint
#  label                                      :integer
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
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

  has_one :note, as: :notable

  def self.users_previous_asr_id(asr_id, abstract_screenings_projects_users_role)
    where(abstract_screenings_projects_users_role:)
      .where('updated_at < ?', AbstractScreeningResult.find(asr_id).updated_at)
      .where('label IS NOT NULL')
      .order(updated_at: :desc)
      .limit(1)&.first&.id
  end

  def self.find_unfinished_abstract_screening_result(abstract_screening, abstract_screenings_projects_users_role)
    where(abstract_screening:)
      .where(abstract_screenings_projects_users_role:)
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
    abstract_screening.evaluate_transition(self)
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

  def self.find_by_asr(asr_id)
    abstract_screening_result = AbstractScreeningResult.find(asr_id)
  end

  def self.find_by_perpetual(abstract_screening, abstract_screenings_projects_users_role)
    citations_project =
      abstract_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .sample
    random_citation = citations_project.citation
    citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)

    abstract_screenings_citations_project =
      abstract_screening
      .abstract_screenings_citations_projects
      .find_or_create_by(
        abstract_screening:,
        citations_project:
          CitationsProject.find_by(
            project: abstract_screening.project, citation: random_citation
          )
      )
    abstract_screening
      .abstract_screening_results
      .create!(label: nil, abstract_screenings_citations_project:,
               abstract_screenings_projects_users_role:)
  end

  def self.find_by_pilot(abstract_screening, abstract_screenings_projects_users_role)
    abstract_screenings_citations_project =
      AbstractScreeningsCitationsProject
      .joins(:abstract_screening, :citations_project)
      .left_joins(:abstract_screening_results)
      .where(abstract_screening:)
      .where(abstract_screening_results: { label: nil })
      .where(citations_projects: { screening_status: [
               CitationsProject::CITATION_POOL,
               CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED,
               CitationsProject::ABSTRACT_SCREENING_UNSCREENED
             ] })
      .sample
    abstract_screening
      .abstract_screening_results
      .create!(label: nil, abstract_screenings_citations_project:,
               abstract_screenings_projects_users_role:)
  end

  def self.next_abstract_screening_result(
    abstract_screening:,
    abstract_screening_result:,
    asr_id:,
    abstract_screenings_projects_users_role:
  )
    if asr_id
      find_by_asr(asr_id)
    elsif abstract_screening_result = AbstractScreeningResult.find_unfinished_abstract_screening_result(
      abstract_screening, abstract_screenings_projects_users_role
    )
      abstract_screening_result
    elsif abstract_screening.abstract_screening_type == AbstractScreening::SINGLE_PERPETUAL ||
          abstract_screening.abstract_screening_type == AbstractScreening::DOUBLE_PERPETUAL
      find_by_perpetual(abstract_screening, abstract_screenings_projects_users_role)
    else
      find_by_pilot(abstract_screening, abstract_screenings_projects_users_role)
    end
  end
end
