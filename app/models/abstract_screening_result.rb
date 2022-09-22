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
  searchkick

  after_commit :reindex_citations_project, :reindex

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

  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :abstract_screening_result

  delegate :project, to: :citations_project

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
      note: note&.value || '',
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

  def reindex_citations_project
    citations_project.reindex
  end
end
