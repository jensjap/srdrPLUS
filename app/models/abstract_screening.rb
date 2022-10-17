class AbstractScreening < ApplicationRecord
  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  N_SIZE_SINGLE = 'n-size-single'.freeze
  N_SIZE_DOUBLE = 'n-size-double'.freeze
  PILOT = 'pilot'.freeze
  ABSTRACTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    N_SIZE_SINGLE => 'Fixed N Size (Single)',
    N_SIZE_DOUBLE => 'Fixed N Size (Double)',
    PILOT => 'Pilot'
  }.freeze

  validates_presence_of :abstract_screening_type

  belongs_to :project
  has_many :abstract_screenings_users
  has_many :users, through: :abstract_screenings_users

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
