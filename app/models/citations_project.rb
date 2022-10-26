# == Schema Information
#
# Table name: citations_projects
#
#  id                :integer          not null, primary key
#  citation_id       :integer
#  project_id        :integer
#  screening_status  :string(255)      default("asu")
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
  has_many :abstract_screening_results, dependent: :destroy
  has_many :fulltext_screening_results, dependent: :destroy
  has_many :screening_qualifications, dependent: :destroy

  has_many :labels, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

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
      'author_map_string' => citation.author_map_string,
      'name' => citation.name,
      'year' => citation.year,
      'users' => abstract_screening_results.map(&:user).uniq.map(&:handle).join(', '),
      'as_labels' => as_label_strings,
      'fs_labels' => fs_label_strings,
      'reasons' => abstract_screening_results.map(&:reasons).flatten.map(&:name).join(', '),
      'tags' => abstract_screening_results.map(&:tags).flatten.map(&:name).join(', '),
      'note' => abstract_screening_results.map(&:notes),
      'screening_status' => screening_status,
      'abstract_qualification' => abstract_qualification,
      'fulltext_qualification' => fulltext_qualification,
      'extraction_qualification' => extraction_qualification,
      'abstract_screening_objects' => abstract_screening_objects,
      'fulltext_screening_objects' => fulltext_screening_objects
    }
  end

  def abstract_qualification
    as_qualification = screening_qualifications.find { |sq| sq.qualification_type[0..1] == 'as' }
    return '-----' unless as_qualification

    manually_qualified_by = as_qualification.user&.handle

    if as_qualification.qualification_type == ScreeningQualification::AS_ACCEPTED && manually_qualified_by
      "Passed: #{manually_qualified_by}"
    elsif as_qualification.qualification_type == ScreeningQualification::AS_ACCEPTED
      'Passed'
    elsif as_qualification.qualification_type == ScreeningQualification::AS_REJECTED && manually_qualified_by
      "Rejected: #{manually_qualified_by}"
    elsif as_qualification.qualification_type == ScreeningQualification::AS_REJECTED
      'Rejected'
    end
  end

  def fulltext_qualification
    fs_qualification = screening_qualifications.find { |sq| sq.qualification_type[0..1] == 'fs' }
    return '-----' unless fs_qualification

    manually_qualified_by = fs_qualification.user&.handle

    if fs_qualification.qualification_type == ScreeningQualification::FS_ACCEPTED && manually_qualified_by
      "Passed: #{manually_qualified_by}"
    elsif fs_qualification.qualification_type == ScreeningQualification::FS_ACCEPTED
      'Passed'
    elsif fs_qualification.qualification_type == ScreeningQualification::FS_REJECTED && manually_qualified_by
      "Rejected: #{manually_qualified_by}"
    elsif fs_qualification.qualification_type == ScreeningQualification::FS_REJECTED
      'Rejected'
    end
  end

  def extraction_qualification
    e_qualification = screening_qualifications.find { |sq| sq.qualification_type[0..1] == 'e-' }
    return '-----' unless e_qualification

    manually_qualified_by = e_qualification.user&.handle

    if e_qualification.qualification_type == ScreeningQualification::E_REJECTED && manually_qualified_by
      "Rejected: #{manually_qualified_by}"
    elsif e_qualification.qualification_type == ScreeningQualification::E_REJECTED
      'Rejected'
    end
  end

  def evaluate_screening_status
    if screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::E_REJECTED }
      update(screening_status: :er)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::FS_REJECTED }
      update(screening_status: :fsr)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::AS_REJECTED }
      update(screening_status: :asr)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::FS_ACCEPTED }
      if Extraction.where(citations_project: self).present?
        update(screening_status: :eip)
      else
        update(screening_status: :ene)
      end
      # update(screening_status: :ec)
    elsif screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::AS_ACCEPTED }
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
