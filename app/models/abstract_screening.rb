# == Schema Information
#
# Table name: abstract_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  abstract_screening_type :string(255)      default("single-perpetual"), not null
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
class AbstractScreening < ApplicationRecord
  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  PILOT = 'pilot'.freeze
  ABSTRACTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    PILOT => 'Pilot'
  }.freeze

  validates_presence_of :abstract_screening_type

  belongs_to :project
  has_many :abstract_screenings_citations_projects
  has_many :citations_projects, through: :abstract_screenings_citations_projects
  has_many :citations, through: :citations_projects
  has_many :abstract_screenings_projects_users_roles
  has_many :projects_users_roles, through: :abstract_screenings_projects_users_roles

  has_many :abstract_screenings_reasons
  has_many :reasons, through: :abstract_screenings_reasons
  has_many :abstract_screenings_tags
  has_many :tags, through: :abstract_screenings_tags

  has_many :abstract_screening_results, dependent: :destroy, inverse_of: :abstract_screening

  def evaluate_transition(abstract_screening_result)
    case abstract_screening_type
    when SINGLE_PERPETUAL, PILOT
      if abstract_screening_result.label == 1
        abstract_screening_result.citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_ACCEPTED)
      elsif abstract_screening_result.label == -1
        abstract_screening_result.citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_REJECTED)
      else
        abstract_screening_result.citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)
      end
    when DOUBLE_PERPETUAL
      citations_project = abstract_screening_result.citations_project
      abstract_screening_results = citations_project.abstract_screening_results
      count = abstract_screening_results.count { |asr| !asr.label.nil? }
      score = abstract_screening_results.sum { |asr| asr.label.nil? ? 0 : asr.label }
      if count >= 2 && count == score
        citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_ACCEPTED)
      elsif count >= 2 && count == -score
        citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_REJECTED)
      elsif count >= 2 && count != score
        citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_IN_CONFLICT)
      elsif count < 2
        citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED)
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
    cps.update_all(screening_status: CitationsProject::ABSTRACT_SCREENING_UNSCREENED)
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

  def finished?
    citations_projects.any? do |cp|
      [CitationsProject::CITATION_POOL, CitationsProject::ABSTRACT_SCREENING_UNSCREENED].include?(cp.screening_status)
    end
  end
end
