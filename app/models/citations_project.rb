# == Schema Information
#
# Table name: citations_projects
#
#  id                :integer          not null, primary key
#  citation_id       :integer
#  project_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  consensus_type_id :integer
#  pilot_flag        :boolean
#  screening_status  :string(255)      default("asu")
#  refman            :text(65535)
#  other_reference   :text(65535)
#

class CitationsProject < ApplicationRecord
  searchkick callbacks: :async,
             mappings: {
               properties: {
                 accession_number_alts: { type: 'keyword' },
                 author_map_string: { type: 'keyword' },
                 name: { type: 'keyword' },
                 year: { type: 'keyword' },
                 abstract_qualification: { type: 'keyword' },
                 fulltext_qualification: { type: 'keyword' },
                 extraction_qualification: { type: 'keyword' },
                 consolidation_qualification: { type: 'keyword' },
                 screening_status: { type: 'keyword' },
               }
             }

  scope :not_disqualified,
        -> { where.not(screening_status: CitationsProject::REJECTED) }

  belongs_to :citation, inverse_of: :citations_projects
  belongs_to :project, inverse_of: :citations_projects # , touch: true

  has_many :extractions, dependent: :destroy
  has_many :abstract_screening_results, dependent: :destroy
  has_many :fulltext_screening_results, dependent: :destroy
  has_many :screening_qualifications, dependent: :destroy
  has_many :ml_predictions, dependent: :destroy

  accepts_nested_attributes_for :citation, reject_if: :all_blank

  AS_UNSCREENED = 'asu'.freeze
  AS_PARTIALLY_SCREENED = 'asps'.freeze
  AS_IN_CONFLICT = 'asic'.freeze
  AS_REJECTED = 'asr'.freeze
  FS_UNSCREENED = 'fsu'.freeze
  FS_PARTIALLY_SCREENED = 'fsps'.freeze
  FS_IN_CONFLICT = 'fsic'.freeze
  FS_REJECTED = 'fsr'.freeze
  E_NEED_EXTRACTION = 'ene'.freeze
  E_IN_PROGRESS = 'eip'.freeze
  E_REJECTED = 'er'.freeze
  E_COMPLETE = 'ec'.freeze
  C_NEED_CONSOLIDATION = 'cnc'.freeze
  C_IN_PROGRESS = 'cip'.freeze
  C_REJECTED = 'cr'.freeze
  C_COMPLETE = 'cc'.freeze
  ALL = [
    AS_UNSCREENED,
    AS_PARTIALLY_SCREENED,
    AS_IN_CONFLICT,
    AS_REJECTED,
    FS_UNSCREENED,
    FS_PARTIALLY_SCREENED,
    FS_IN_CONFLICT,
    FS_REJECTED,
    E_NEED_EXTRACTION,
    E_IN_PROGRESS,
    E_REJECTED,
    E_COMPLETE,
    C_NEED_CONSOLIDATION,
    C_IN_PROGRESS,
    C_REJECTED,
    C_COMPLETE
  ]
  REJECTED = [
    AS_REJECTED,
    FS_REJECTED,
    E_REJECTED,
    C_REJECTED
  ]

  # We find all CitationsProject entries that have the exact same citation_id
  # and project_id. Then we pick the first (oldest) one. We refer to it as the
  # "Master CP" and link associations from all other CitationsProject entries
  # to the "Master CP"
  def dedupe
    citations_projects = CitationsProject.where(
      citation_id:,
      project_id:
    ).to_a
    master_citations_project = citations_projects.shift
    citations_projects.each do |cp|
      CitationsProject.dedupe_update_associations(master_citations_project, cp)
      cp.destroy
    end
  end

  def self.dedupe_update_associations(master_cp, cp_to_remove)
    cp_to_remove.extractions.each do |e|
      e.dup.update(citations_project_id: master_cp.id)
    end
  end

  def search_data
    abstract_screenings_by_group = abstract_screening_results.group_by { |asr| asr.abstract_screening }
    as_label_strings = []
    abstract_screenings_by_group.each do |as, asrs|
      asrs_strings = asrs.map { |asr| asr.label || 'null' }.join(', ')
      as_label_strings << "#{as.abstract_screening_type}: #{asrs_strings}"
    end
    fulltext_screenings_by_group = fulltext_screening_results.group_by { |fsr| fsr.fulltext_screening }
    fs_label_strings = []
    fulltext_screenings_by_group.each do |fs, fsrs|
      fsrs_strings = fsrs.map { |fsr| fsr.label || 'null' }.join(', ')
      fs_label_strings << "#{fs.fulltext_screening_type}: #{fsrs_strings}"
    end

    abstract_screening_objects = []
    abstract_screenings_by_group.each do |as, asrs|
      asr_objs = { type: as.abstract_screening_type, asrs: [] }
      asrs.each do |asr|
        asr_obj = {}
        asr_obj[:user] = asr.user.handle
        asr_obj[:label] = asr.label
        asr_obj[:privileged] = asr.privileged
        asr_obj[:reasons] = asr.reasons.map(&:name).join(', ')
        asr_obj[:tags] = asr.tags.map(&:name).join(', ')
        asr_obj[:notes] = asr.notes
        asr_objs[:asrs] << asr_obj
      end
      abstract_screening_objects << asr_objs
    end
    fulltext_screening_objects = []
    fulltext_screenings_by_group.each do |fs, fsrs|
      fsr_objs = { type: fs.fulltext_screening_type, fsrs: [] }
      fsrs.each do |fsr|
        fsr_obj = {}
        fsr_obj[:user] = fsr.user.handle
        fsr_obj[:label] = fsr.label
        fsr_obj[:privileged] = fsr.privileged
        fsr_obj[:reasons] = fsr.reasons.map(&:name).join(', ')
        fsr_obj[:tags] = fsr.tags.map(&:name).join(', ')
        fsr_obj[:notes] = fsr.notes
        fsr_objs[:fsrs] << fsr_obj
      end
      fulltext_screening_objects << fsr_objs
    end

    {
      'project_id' => project_id,
      'citations_project_id' => id,
      'citation_id' => citation.id,
      'accession_number_alts' => citation.accession_number_alts,
      'author_map_string' => citation.authors.to_s.truncate(20_000),
      'name' => citation.name.to_s,
      'year' => citation.year.to_s,
      'publication' => "#{citation.journal&.name} #{citation.journal&.volume}(#{citation.journal&.issue}):#{citation&.page_number_start}-#{citation&.page_number_end}",
      'publication_date' => formatted_publication_date(citation.journal&.publication_date),
      'doi' => citation.doi.to_s,
      'keywords' => citation.keywords.map(&:name).join(', '),
      'users' => abstract_screening_results.map(&:user).uniq.map(&:handle).join(', '),
      'as_labels' => as_label_strings,
      'fs_labels' => fs_label_strings,
      'reasons' => abstract_screening_results.map(&:reasons).flatten.map(&:name).join(', '),
      'tags' => abstract_screening_results.map(&:tags).flatten.map(&:name).join(', '),
      'note' => abstract_screening_results.map(&:notes),
      'screening_status' => screening_status,
      'abstract_qualification' => qualification('as'),
      'fulltext_qualification' => qualification('fs'),
      'extraction_qualification' => qualification('e-'),
      'consolidation_qualification' => qualification('c-'),
      'abstract_screening_objects' => abstract_screening_objects,
      'fulltext_screening_objects' => fulltext_screening_objects,
      'abstract' => citation.abstract.force_encoding("ISO-8859-1").encode("UTF-8"),
      'pmid' => citation.pmid,
      'refman' => refman,
      'accession_number' => citation.accession_number
    }
  end

  def qualification(prefix)
    qualification = screening_qualifications.find { |sq| sq.qualification_type[0..1] == prefix }
    return '.....' unless qualification

    manually_qualified_by = qualification.user&.handle
    qualification_text =
      if qualification.qualification_type.ends_with?('accepted')
        'Passed'
      elsif qualification.qualification_type.ends_with?('rejected')
        'Rejected'
      end
    qualification_text += ": #{manually_qualified_by}" if manually_qualified_by

    qualification_text
  end

  def evaluate_extraction_qualification_status(consolidated)
    qualification_type = consolidated ? ScreeningQualification::C_ACCEPTED : ScreeningQualification::E_ACCEPTED
    undestroyed_extractions = extractions.where(consolidated:).reject(&:destroyed?)
    all_complete = undestroyed_extractions.present? && undestroyed_extractions.all? do |extraction|
      extraction.extractions_extraction_forms_projects_sections.present? && extraction.extractions_extraction_forms_projects_sections.all? do |eefps|
        eefps.status.name == 'Completed'
      end
    end

    sqs_extraction_accepted = screening_qualifications.where(qualification_type:)

    if all_complete && sqs_extraction_accepted.blank?
      screening_qualifications.create(qualification_type:)
    elsif !all_complete
      screening_qualifications.where(
        qualification_type:, user_id: nil
      ).destroy_all
    end
  end

  def evaluate_screening_status
    consolidated_extraction = Extraction.includes(extractions_extraction_forms_projects_sections: :status).where(
      citations_project: self, consolidated: true
    ).first
    extractions = Extraction
                  .includes(extractions_extraction_forms_projects_sections: :status)
                  .where(citations_project: self)

    if screening_qualifications.where(qualification_type: ScreeningQualification::C_REJECTED).present?
      update(screening_status: C_REJECTED)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::C_ACCEPTED).present?
      update(screening_status: C_COMPLETE)
    elsif consolidated_extraction.present?
      update(screening_status: C_IN_PROGRESS)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::E_REJECTED).present?
      update(screening_status: E_REJECTED)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::E_ACCEPTED).present?
      update(screening_status: C_NEED_CONSOLIDATION)
    elsif extractions.present?
      update(screening_status: E_IN_PROGRESS)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::FS_REJECTED).present?
      update(screening_status: FS_REJECTED)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::FS_ACCEPTED).present?
      update(screening_status: E_NEED_EXTRACTION)
    elsif (fulltext_screening_results.where(label: -1).present? && fulltext_screening_results.where(label: 1).present?) ||
          fulltext_screening_results.where(label: 0).present?
      update(screening_status: FS_IN_CONFLICT)
    elsif fulltext_screening_results.present?
      update(screening_status: FS_PARTIALLY_SCREENED)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::AS_REJECTED).present?
      update(screening_status: AS_REJECTED)
    elsif screening_qualifications.where(qualification_type: ScreeningQualification::AS_ACCEPTED).present?
      update(screening_status: FS_UNSCREENED)
    elsif (abstract_screening_results.where(label: -1).present? && abstract_screening_results.where(label: 1).present?) ||
          abstract_screening_results.where(label: 0).present?
      update(screening_status: AS_IN_CONFLICT)
    elsif abstract_screening_results.present?
      update(screening_status: AS_PARTIALLY_SCREENED)
    else
      update(screening_status: AS_UNSCREENED)
    end

    reindex(mode: :async)
  end

  private

  def formatted_publication_date(date)
    return nil unless date
    case date
    # 2010-04-30
    when /\d{4}-\d{2}-\d{2}/
      $1.to_s
    # 2023
    when /\d{4}/
      $1.to_s
    # 2001 Sep 15-23
    when /\d{4}[\s-]?\w{3}[\s-]?\d{1,2}([-\s]?\d+)?/
      $1.to_s
    # 2001 Sep
    when /\d{4}[\s-]?\w{3}/
      $1.to_s
    # 1985 Jul-Aug
    when /\d{4}[\s-]?\w{3}-\w{3}/
      $1.to_s
    else
      nil
    end
  end
end
