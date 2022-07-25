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

  def self.users_previous_fulltext_screening_result_id(fulltext_screening_result_id, fulltext_screenings_projects_users_role)
    where(fulltext_screenings_projects_users_role:)
      .where('updated_at < ?', find(fulltext_screening_result_id).updated_at)
      .where('label IS NOT NULL')
      .order(updated_at: :desc)
      .limit(1)&.first&.id
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

  def self.create_draft_asr(
    fulltext_screening:,
    fulltext_screenings_citations_project:,
    fulltext_screenings_projects_users_role:
  )
    fulltext_screening
      .fulltext_screening_results
      .create!(
        label: nil,
        fulltext_screenings_citations_project:,
        fulltext_screenings_projects_users_role:
      )
  end

  def self.next_fulltext_screening_result(
    fulltext_screening:,
    fulltext_screening_result_id:,
    fulltext_screenings_projects_users_role:
  )
    if fulltext_screening_result_id
      find_by(id: fulltext_screening_result_id)
    elsif fulltext_screening_result = find_by_unfinished_fulltext_screening_result(
      fulltext_screening, fulltext_screenings_projects_users_role
    )
      fulltext_screening_result
    elsif fulltext_screening.fulltext_screening_type == AbstractScreening::SINGLE_PERPETUAL
      find_by_single_perpetual(
        fulltext_screening,
        fulltext_screenings_projects_users_role
      )
    elsif fulltext_screening.fulltext_screening_type == AbstractScreening::DOUBLE_PERPETUAL
      find_by_double_perpetual(
        fulltext_screening,
        fulltext_screenings_projects_users_role
      )
    else
      find_by_pilot(
        fulltext_screening,
        fulltext_screenings_projects_users_role
      )
    end
  end

  def self.find_by_unfinished_fulltext_screening_result(fulltext_screening, fulltext_screenings_projects_users_role)
    where(fulltext_screening:)
      .where(fulltext_screenings_projects_users_role:)
      .where('label IS NULL')
      .first
  end

  def self.find_by_single_perpetual(fulltext_screening, fulltext_screenings_projects_users_role)
    citations_project =
      fulltext_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .sample
    return nil unless citations_project

    citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)

    fulltext_screenings_citations_project =
      fulltext_screening
      .fulltext_screenings_citations_projects
      .find_or_create_by(
        fulltext_screening:,
        citations_project:
      )
    create_draft_asr(
      fulltext_screening:,
      fulltext_screenings_citations_project:,
      fulltext_screenings_projects_users_role:
    )
  end

  def self.find_by_double_perpetual(fulltext_screening, fulltext_screenings_projects_users_role)
    citations_project =
      fulltext_screening
      .project
      .citations_projects
      .joins(:fulltext_screening_results)
      .where(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)
      .where.not(fulltext_screening_results: { fulltext_screenings_projects_users_role: :fulltext_screenings_projects_users_role })
      .sample

    citations_project ||=
      fulltext_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .sample
    return nil unless citations_project

    citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)

    fulltext_screenings_citations_project =
      fulltext_screening
      .fulltext_screenings_citations_projects
      .find_or_create_by(
        fulltext_screening:,
        citations_project:
      )
    create_draft_asr(
      fulltext_screening:,
      fulltext_screenings_citations_project:,
      fulltext_screenings_projects_users_role:
    )
  end

  def self.find_by_pilot(fulltext_screening, fulltext_screenings_projects_users_role)
    fulltext_screenings_citations_project =
      AbstractScreeningsCitationsProject
      .joins(:fulltext_screening, :citations_project)
      .left_joins(:fulltext_screening_results)
      .where(fulltext_screening:)
      .where(fulltext_screening_results: { label: nil })
      .where(citations_projects: { screening_status: [
               CitationsProject::CITATION_POOL,
               CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED,
               CitationsProject::FULLTEXT_SCREENING_UNSCREENED
             ] })
      .sample
    return nil unless fulltext_screenings_citations_project

    create_draft_asr(
      fulltext_screening:,
      fulltext_screenings_citations_project:,
      fulltext_screenings_projects_users_role:
    )
  end
end
