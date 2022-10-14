class AbstractScreeningResult < ApplicationRecord
  searchkick

  belongs_to :abstract_screening
  belongs_to :citation
  belongs_to :user

  has_many :abstract_screening_results_reasons
  has_many :reasons, through: :abstract_screening_results_reasons
  has_many :abstract_screening_results_tags
  has_many :tags, through: :abstract_screening_results_tags
  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :abstract_screening_result

  delegate :project, to: :abstract_screening
  accepts_nested_attributes_for :abstract_screening_results_reasons, allow_destroy: true

  def self.work
    asr.update(
      abstract_screening_results_reasons_attributes: [
        reason_id: 1,
        abstract_screening_result_id: 1
      ]
    )
  end

  def self.asr
    AbstractScreeningResult.find_by(abstract_screening_id: 1, citation: Citation.last, user: User.first)
  end

  def search_data
    {
      id:,
      abstract_screening_id:,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.author_map_string,
      name: citation.name,
      year: citation.year,
      user: user.handle,
      label:,
      reasons: reasons.map(&:name).join(', '),
      tags: tags.map(&:name).join(', '),
      notes:,
      updated_at:
    }
  end

  def self.users_previous_abstract_screening_result_id(abstract_screening_result_id, abstract_screenings_projects_users_role)
    where(abstract_screenings_projects_users_role:)
      .where('updated_at < ?', find(abstract_screening_result_id).updated_at)
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

  def self.create_draft_asr(
    abstract_screening:,
    abstract_screenings_citations_project:,
    abstract_screenings_projects_users_role:
  )
    abstract_screening
      .abstract_screening_results
      .create!(
        label: nil,
        abstract_screenings_citations_project:,
        abstract_screenings_projects_users_role:
      )
  end

  def self.next_abstract_screening_result(
    abstract_screening:,
    abstract_screening_result_id:,
    abstract_screenings_projects_users_role:
  )
    if abstract_screening_result_id
      find_by(id: abstract_screening_result_id)
    elsif abstract_screening_result = find_by_unfinished_abstract_screening_result(
      abstract_screening, abstract_screenings_projects_users_role
    )
      abstract_screening_result
    elsif abstract_screening.abstract_screening_type == AbstractScreening::SINGLE_PERPETUAL
      find_by_single_perpetual(
        abstract_screening,
        abstract_screenings_projects_users_role
      )
    elsif abstract_screening.abstract_screening_type == AbstractScreening::DOUBLE_PERPETUAL
      find_by_double_perpetual(
        abstract_screening,
        abstract_screenings_projects_users_role
      )
    else
      find_by_pilot(
        abstract_screening,
        abstract_screenings_projects_users_role
      )
    end
  end

  def self.find_by_unfinished_abstract_screening_result(abstract_screening, abstract_screenings_projects_users_role)
    where(abstract_screening:)
      .where(abstract_screenings_projects_users_role:)
      .where('label IS NULL')
      .first
  end

  def self.find_by_single_perpetual(abstract_screening, abstract_screenings_projects_users_role)
    citations_project =
      abstract_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .sample
    return nil unless citations_project

    citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)

    abstract_screenings_citations_project =
      abstract_screening
      .abstract_screenings_citations_projects
      .find_or_create_by(
        abstract_screening:,
        citations_project:
      )
    create_draft_asr(
      abstract_screening:,
      abstract_screenings_citations_project:,
      abstract_screenings_projects_users_role:
    )
  end

  def self.find_by_double_perpetual(abstract_screening, abstract_screenings_projects_users_role)
    processed_cp_ids = abstract_screenings_projects_users_role.abstract_screening_results.map(&:citations_project).map(&:id)
    citations_project =
      abstract_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)
      .where.not({ id: processed_cp_ids })
      .first
    citations_project ||=
      abstract_screening
      .project
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .first
    return nil unless citations_project

    citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)

    abstract_screenings_citations_project =
      abstract_screening
      .abstract_screenings_citations_projects
      .find_or_create_by(
        abstract_screening:,
        citations_project:
      )
    create_draft_asr(
      abstract_screening:,
      abstract_screenings_citations_project:,
      abstract_screenings_projects_users_role:
    )
  end

  def self.find_by_pilot(abstract_screening, abstract_screenings_projects_users_role)
    processed_cp_ids = abstract_screenings_projects_users_role.abstract_screening_results.map(&:citations_project).map(&:id)
    citations_project =
      abstract_screening
      .citations_projects
      .where(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)
      .where.not({ id: processed_cp_ids })
      .first
    citations_project ||=
      abstract_screening
      .citations_projects
      .where(screening_status: CitationsProject::CITATION_POOL)
      .first
    return nil unless citations_project

    abstract_screenings_citations_project =
      abstract_screening
      .abstract_screenings_citations_projects
      .find_or_create_by(
        abstract_screening:,
        citations_project:
      )

    create_draft_asr(
      abstract_screening:,
      abstract_screenings_citations_project:,
      abstract_screenings_projects_users_role:
    )
  end
end
