# == Schema Information
#
# Table name: fulltext_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  fulltext_screening_type :string(255)      default("single-perpetual"), not null
#  yes_tag_required        :boolean          default(FALSE), not null
#  no_tag_required         :boolean          default(FALSE), not null
#  maybe_tag_required      :boolean          default(FALSE), not null
#  yes_reason_required     :boolean          default(FALSE), not null
#  no_reason_required      :boolean          default(FALSE), not null
#  maybe_reason_required   :boolean          default(FALSE), not null
#  yes_note_required       :boolean          default(FALSE), not null
#  no_note_required        :boolean          default(FALSE), not null
#  maybe_note_required     :boolean          default(FALSE), not null
#  only_predefined_reasons :boolean          default(FALSE), not null
#  only_predefined_tags    :boolean          default(FALSE), not null
#  hide_author             :boolean          default(FALSE), not null
#  hide_journal            :boolean          default(FALSE), not null
#  exclusive_participants  :boolean          default(FALSE), not null
#  default                 :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class FulltextScreening < ApplicationRecord
  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  PILOT = 'pilot'.freeze
  FULLTEXTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    PILOT => 'Pilot'
  }.freeze

  validates_presence_of :fulltext_screening_type

  belongs_to :project
  has_many :fulltext_screenings_citations_projects
  has_many :citations_projects, through: :fulltext_screenings_citations_projects
  has_many :citations, through: :citations_projects
  has_many :fulltext_screenings_projects_users_roles
  has_many :projects_users_roles, through: :fulltext_screenings_projects_users_roles

  has_many :fulltext_screenings_reasons
  has_many :reasons, through: :fulltext_screenings_reasons
  has_many :fulltext_screenings_tags
  has_many :tags, through: :fulltext_screenings_tags

  has_many :fulltext_screening_results, dependent: :destroy, inverse_of: :fulltext_screening

  def evaluate_transition(fulltext_screening_result)
    case fulltext_screening_type
    when SINGLE_PERPETUAL, PILOT
      if fulltext_screening_result.label == 1
        fulltext_screening_result.citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_ACCEPTED)
      elsif fulltext_screening_result.label == -1
        fulltext_screening_result.citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_REJECTED)
      else
        fulltext_screening_result.citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)
      end
    when DOUBLE_PERPETUAL
      citations_project = fulltext_screening_result.citations_project
      fulltext_screening_results = citations_project.fulltext_screening_results
      count = fulltext_screening_results.count { |asr| !asr.label.nil? }
      score = fulltext_screening_results.sum { |asr| asr.label.nil? ? 0 : asr.label }
      if count >= 2 && count == score
        citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_ACCEPTED)
      elsif count >= 2 && count == -score
        citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_REJECTED)
      elsif count >= 2 && count != score
        citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_IN_CONFLICT)
      elsif count < 2
        citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)
      end
    end
  end

  def reasons_object
    reasons.each_with_object({}) do |reason, hash|
      hash[reason.name] = false
      hash
    end
  end

  def tags_object
    tags.each_with_object({}) do |tag, hash|
      hash[tag.name] = false
      hash
    end
  end

  def add_citations_from_pool(no_of_citations)
    return if no_of_citations.nil?

    no_of_citations_to_add = no_of_citations - citations.count
    return unless no_of_citations_to_add.positive?

    cps = project.citations_projects.where(screening_status: CitationsProject::CITATION_POOL).limit(no_of_citations_to_add)
    citations_projects << cps
  end

  def tag_options
    reqs = []
    reqs << 'Yes' if yes_tag_required
    reqs << 'No' if no_tag_required
    reqs << 'Maybe' if maybe_tag_required
    reqs
  end

  def reason_options
    reqs = []
    reqs << 'Yes' if yes_reason_required
    reqs << 'No' if no_reason_required
    reqs << 'Maybe' if maybe_reason_required
    reqs
  end

  def note_options
    reqs = []
    reqs << 'Yes' if yes_note_required
    reqs << 'No' if no_note_required
    reqs << 'Maybe' if maybe_note_required
    reqs
  end
end
