# == Schema Information
#
# Table name: fulltext_screening_results
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint
#  user_id               :bigint
#  citations_project_id  :bigint
#  label                 :integer
#  notes                 :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  privileged            :boolean          default(FALSE)
#  form_complete         :boolean          default(FALSE), not null
#
class FulltextScreeningResult < ApplicationRecord
  searchkick callbacks: :async,
             mappings: {
               properties: {
                 name: { type: 'keyword' }
               }
             }

  belongs_to :fulltext_screening
  belongs_to :citations_project
  belongs_to :user

  has_many :fulltext_screening_results_reasons
  has_many :reasons, through: :fulltext_screening_results_reasons
  has_many :fulltext_screening_results_tags
  has_many :tags, through: :fulltext_screening_results_tags
  has_many :sf_fulltext_records, dependent: :destroy, inverse_of: :fulltext_screening_result

  delegate :project, to: :fulltext_screening
  delegate :citation, to: :citations_project

  after_commit :evaluate_screening_qualifications

  def reasons_object
    FulltextScreeningResultsReason
      .where(fulltext_screening_results: self)
      .includes(:reason)
      .map do |fulltext_screening_results_reason|
      {
        id: fulltext_screening_results_reason.id,
        reason_id: fulltext_screening_results_reason.reason_id,
        name: fulltext_screening_results_reason.reason.name,
        pos: 99_999,
        selected: true
      }
    end
  end

  def evaluate_screening_qualifications
    return if citations_project.marked_for_destruction?

    manual_sqs = citations_project
                 .screening_qualifications
                 .where("qualification_type LIKE 'fs-%'")
                 .where.not(user: nil)

    if manual_sqs.present? || (!privileged && citations_project.fulltext_screening_results.any?(&:privileged))
      # evaluate screening status anyway
    elsif destroyed?
      citations_project.screening_qualifications.where("qualification_type LIKE 'fs-%'").where(user: nil).destroy_all
      citations_project.fulltext_screening_results.each do |fsr|
        next if fsr.id == id

        fsr.evaluate_screening_qualifications
      end
    elsif privileged || citations_project_sufficiently_labeled?
      case label
      when 1
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_REJECTED).destroy_all
        citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::FS_ACCEPTED)
      when -1
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_ACCEPTED).destroy_all
        citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::FS_REJECTED)
      when 0
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_ACCEPTED).destroy_all
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_REJECTED).destroy_all
      end
    elsif label.try(:zero?) && citations_project.fulltext_screening_results.none?(&:privileged)
      citations_project.screening_qualifications.where("qualification_type LIKE 'fs-%'").destroy_all
    end

    citations_project.evaluate_screening_status
  end

  def citations_project_sufficiently_labeled?
    return true if fulltext_screening.single_screening?

    if fulltext_screening.exclusive_users
      relevant_fsrs = FulltextScreeningResult.where(
        privileged: false,
        fulltext_screening:,
        citations_project:,
        user: fulltext_screening.users
      )
      required_fsrs_pilot_count = fulltext_screening.fulltext_screenings_users.count
    else
      relevant_fsrs = FulltextScreeningResult.where(
        privileged: false,
        fulltext_screening:,
        citations_project:
      )
      required_fsrs_pilot_count = fulltext_screening.project.projects_users.count
    end
    return false unless relevant_fsrs.all? { |fsr| fsr.label == 1 } || relevant_fsrs.all? { |fsr| fsr.label == -1 }

    (fulltext_screening.double_screening? && relevant_fsrs.count == 2) ||
      (fulltext_screening.all_screenings? && relevant_fsrs.count == required_fsrs_pilot_count)
  end

  def search_data
    {
      id:,
      fulltext_screening_id:,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.authors.to_s,
      name: citation.name.to_s,
      year: citation.year.to_s,
      user: user.handle,
      user_id:,
      label:,
      privileged:,
      reasons: reasons.map(&:name).join(', '),
      tags: tags.map(&:name).join(', '),
      notes:,
      updated_at:
    }
  end
end
