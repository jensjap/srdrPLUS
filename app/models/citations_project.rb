# == Schema Information
#
# Table name: citations_projects
#
#  id                :integer          not null, primary key
#  citation_id       :integer
#  project_id        :integer
#  screening_status  :string(255)
#  deleted_at        :datetime
#  active            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  consensus_type_id :integer
#  pilot_flag        :boolean
#

class CitationsProject < ApplicationRecord
  searchkick
  include SharedParanoiaMethods

  after_commit :reindex

  acts_as_paranoid column: :active, sentinel_value: true

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
  has_many :abstract_screening_results
  has_many :fulltext_screening_results
  has_many :screening_qualifications, dependent: :destroy

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
      CitationsProject.dedupe_update_associations(master_citations_project, cp)
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

  def search_data
    abstract_screenings_by_group = abstract_screening_results.group_by { |asr| asr.abstract_screening }
    label_strings = []
    abstract_screenings_by_group.each do |as, asrs|
      asrs_strings = asrs.map { |asr| asr.label || 'null' }.join(', ')
      label_strings << "#{as.abstract_screening_type}: #{asrs_strings}"
    end
    {
      project_id:,
      citations_project_id: id,
      citation_id: citation.id,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.author_map_string,
      name: citation.name,
      year: citation.year,
      users: abstract_screening_results.map(&:user).uniq.map(&:handle).join(', '),
      as_labels: label_strings,
      fs_labels: [],
      reasons: abstract_screening_results.map(&:reasons).flatten.map(&:name).join(', '),
      tags: abstract_screening_results.map(&:tags).flatten.map(&:name).join(', '),
      note: abstract_screening_results.map(&:notes).compact.join(', '),
      screening_status:
    }
  end

  def evaluate_screening_status
    if screening_qualifications.any? { |sq| sq.qualification_type == 'ft-rejected' }
      update(screening_status: :fsr)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == 'as-rejected' }
      update(screening_status: :asr)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == 'ft-accepted' }
      # TODOS
      # update(screening_status: :ene)
      # update(screening_status: :eip)
      # update(screening_status: :ec)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == 'as-accepted' }
      if fulltext_screening_results.blank?
        update(screening_status: :fsu)
      elsif fulltext_screening_results.any? { |fsr| fsr.label == -1 } &&
            fulltext_screening_results.any? { |fsr| fsr.label == 1 }
        update(screening_status: :fsic)
      else
        update(screening_status: :fsps)
      end
    elsif screening_qualifications.blank?
      if abstract_screening_results.blank?
        update(screening_status: :asu)
      elsif abstract_screening_results.any? { |asr| asr.label == -1 } &&
            abstract_screening_results.any? { |asr| asr.label == 1 }
        update(screening_status: :asic)
      else
        update(screening_status: :asps)
      end
    end
    reindex
  end
end
