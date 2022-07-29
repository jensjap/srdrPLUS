# == Schema Information
#
# Table name: citations_projects
#
#  id                :integer          not null, primary key
#  citation_id       :integer
#  project_id        :integer
#  deleted_at        :datetime
#  active            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  consensus_type_id :integer
#  pilot_flag        :boolean
#  screening_status  :string(255)      default("CP"), not null
#

class CitationsProject < ApplicationRecord
  searchkick
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  CITATION_POOL = 'CP'.freeze
  ABSTRACT_SCREENING_UNSCREENED = 'ASU'.freeze
  ABSTRACT_SCREENING_PARTIALLY_SCREENED = 'ASPS'.freeze
  ABSTRACT_SCREENING_REJECTED = 'ASR'.freeze
  ABSTRACT_SCREENING_IN_CONFLICT = 'ASIC'.freeze
  ABSTRACT_SCREENING_ACCEPTED = 'ASA'.freeze
  FULLTEXT_SCREENING_UNSCREENED = 'FTU'.freeze
  FULLTEXT_SCREENING_PARTIALLY_SCREENED = 'FTPS'.freeze
  FULLTEXT_SCREENING_REJECTED = 'FTR'.freeze
  FULLTEXT_SCREENING_IN_CONFLICT = 'FTIC'.freeze
  FULLTEXT_SCREENING_ACCEPTED = 'FTA'.freeze
  DATA_EXTRACTION_NOT_YET_EXTRACTED = 'DENYE'.freeze
  DATA_EXTRACTION_IN_PROGRESS = 'DEIP'.freeze
  COMPLETED = 'C'.freeze

  DEMOTE = 'demote'.freeze
  PROMOTE = 'promote'.freeze

  scope :unlabeled,
        lambda { |project, count|
          includes(citation: [{ authors_citations: [:author] }, :keywords, :journal])
            .left_outer_joins(:labels)
            .where(labels: { id: nil },
                   project_id: project.id)
            .distinct
            .limit(count)
        }

  scope :labeled,
        lambda { |project, count|
          includes({ :citation => [{ authors_citations: [:author] }, :keywords, :journal],
                     labels => [:reasons] })
            .joins(:labels)
            .where(project_id: project.id)
            .distinct
            .limit(count)
        }

  belongs_to :citation, inverse_of: :citations_projects
  belongs_to :project, inverse_of: :citations_projects, touch: true

  has_one :prediction, dependent: :destroy
  has_one :priority, dependent: :destroy

  has_many :extractions, dependent: :destroy
  has_many :abstract_screenings_citations_projects
  has_many :abstract_screening_results, through: :abstract_screenings_citations_projects
  has_many :citations_projects_fulltext_screenings
  has_many :fulltext_screening_results, through: :citations_projects_fulltext_screenings

  has_many :labels, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_and_belongs_to_many :abstract_screenings
  has_and_belongs_to_many :fulltext_screenings

  accepts_nested_attributes_for :citation, reject_if: :all_blank

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
      dedupe_update_associations(master_citations_project, cp)
      cp.destroy
    end
  end

  def self.dedupe_update_associations(master_cp, cp_to_remove)
    cp_to_remove.extractions.each do |e|
      e.dup.update_attributes(citations_project_id: master_cp.id)
    end
    cp_to_remove.labels.each do |l|
      l.dup.update_attributes(citations_project_id: master_cp.id)
    end
    cp_to_remove.notes.each do |n|
      n.dup.update_attributes(notable_id: master_cp.id)
    end
    cp_to_remove.taggings.each do |t|
      t.dup.update_attributes(taggable_id: master_cp.id)
    end
  end

  def promote
    case screening_status
    when CITATION_POOL
      update(screening_status: ABSTRACT_SCREENING_UNSCREENED)
    when ABSTRACT_SCREENING_UNSCREENED
      update(screening_status: ABSTRACT_SCREENING_PARTIALLY_SCREENED)
    when ABSTRACT_SCREENING_PARTIALLY_SCREENED
      update(screening_status: ABSTRACT_SCREENING_REJECTED)
    when ABSTRACT_SCREENING_REJECTED
      update(screening_status: ABSTRACT_SCREENING_IN_CONFLICT)
    when ABSTRACT_SCREENING_IN_CONFLICT
      update(screening_status: ABSTRACT_SCREENING_ACCEPTED)
    when ABSTRACT_SCREENING_ACCEPTED
      update(screening_status: FULLTEXT_SCREENING_UNSCREENED)
    when FULLTEXT_SCREENING_UNSCREENED
      update(screening_status: FULLTEXT_SCREENING_PARTIALLY_SCREENED)
    when FULLTEXT_SCREENING_PARTIALLY_SCREENED
      update(screening_status: FULLTEXT_SCREENING_REJECTED)
    when FULLTEXT_SCREENING_REJECTED
      update(screening_status: FULLTEXT_SCREENING_IN_CONFLICT)
    when FULLTEXT_SCREENING_IN_CONFLICT
      update(screening_status: FULLTEXT_SCREENING_ACCEPTED)
    when FULLTEXT_SCREENING_ACCEPTED
      update(screening_status: DATA_EXTRACTION_NOT_YET_EXTRACTED)
    when DATA_EXTRACTION_NOT_YET_EXTRACTED
      update(screening_status: DATA_EXTRACTION_IN_PROGRESS)
    when DATA_EXTRACTION_IN_PROGRESS
      update(screening_status: COMPLETED)
    when COMPLETED
      update(screening_status: COMPLETED)
    end
  end

  def demote
    case screening_status
    when CITATION_POOL
      update(screening_status: CITATION_POOL)
    when ABSTRACT_SCREENING_UNSCREENED
      update(screening_status: CITATION_POOL)
    when ABSTRACT_SCREENING_PARTIALLY_SCREENED
      update(screening_status: ABSTRACT_SCREENING_UNSCREENED)
    when ABSTRACT_SCREENING_REJECTED
      update(screening_status: ABSTRACT_SCREENING_PARTIALLY_SCREENED)
    when ABSTRACT_SCREENING_IN_CONFLICT
      update(screening_status: ABSTRACT_SCREENING_REJECTED)
    when ABSTRACT_SCREENING_ACCEPTED
      update(screening_status: ABSTRACT_SCREENING_IN_CONFLICT)
    when FULLTEXT_SCREENING_UNSCREENED
      update(screening_status: ABSTRACT_SCREENING_ACCEPTED)
    when FULLTEXT_SCREENING_PARTIALLY_SCREENED
      update(screening_status: FULLTEXT_SCREENING_UNSCREENED)
    when FULLTEXT_SCREENING_REJECTED
      update(screening_status: FULLTEXT_SCREENING_PARTIALLY_SCREENED)
    when FULLTEXT_SCREENING_IN_CONFLICT
      update(screening_status: FULLTEXT_SCREENING_REJECTED)
    when FULLTEXT_SCREENING_ACCEPTED
      update(screening_status: FULLTEXT_SCREENING_IN_CONFLICT)
    when DATA_EXTRACTION_NOT_YET_EXTRACTED
      update(screening_status: FULLTEXT_SCREENING_ACCEPTED)
    when DATA_EXTRACTION_IN_PROGRESS
      update(screening_status: DATA_EXTRACTION_NOT_YET_EXTRACTED)
    when COMPLETED
      update(screening_status: DATA_EXTRACTION_IN_PROGRESS)
    end
  end

  def search_data
    {
      project_id:,
      citations_project_id: id,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.author_map_string,
      name: citation.name,
      year: citation.year,
      users: abstract_screening_results.map(&:user).uniq.map(&:handle).join(', '),
      labels: abstract_screening_results.map(&:label).join(', '),
      reasons: abstract_screening_results.map(&:reasons).flatten.map(&:name).join(', '),
      tags: abstract_screening_results.map(&:tags).flatten.map(&:name).join(', '),
      note: abstract_screening_results.map(&:note).compact.map(&:value).join(', '),
      screening_status:
    }
  end
end
