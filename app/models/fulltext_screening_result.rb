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
#
class FulltextScreeningResult < ApplicationRecord
  searchkick callbacks: :async

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

  after_save :evaluate_screening_qualifications

  def evaluate_screening_qualifications
    if citations_project
       .screening_qualifications
       .where.not(user: nil)
       .where("qualification_type LIKE 'fs-%'")
       .blank? &&
       citations_project_sufficiently_labeled?
      case label
      when 1
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_REJECTED).destroy_all
        citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::FS_ACCEPTED)
      when -1
        citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::FS_ACCEPTED).destroy_all
        citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::FS_REJECTED)
      end
    end

    citations_project.evaluate_screening_status
  end

  def citations_project_sufficiently_labeled?
    return true if fulltext_screening.single_screening?

    if fulltext_screening.exclusive_users
      relevant_fsrs = FulltextScreeningResult.where(fulltext_screening:, citations_project:,
                                                    user: fulltext_screening.users)
      required_fsrs_pilot_count = fulltext_screening.fulltext_screenings_users.count
    else
      relevant_fsrs = FulltextScreeningResult.where(fulltext_screening:, citations_project:)
      required_fsrs_pilot_count = fulltext_screening.project.projects_users.count
    end
    return false unless relevant_fsrs.all? { |fsr| fsr.label == 1 } || relevant_fsrs.all? { |fsr| fsr.label == -1 }

    if fulltext_screening.double_screening? && relevant_fsrs.count == 2
      true
    elsif fulltext_screening.all_screenings? && relevant_fsrs.count == required_fsrs_pilot_count
      true
    else
      false
    end
  end

  def search_data
    {
      id:,
      fulltext_screening_id:,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.author_map_string,
      name: citation.name,
      year: citation.year,
      user: user.handle,
      user_id:,
      label:,
      reasons: reasons.map(&:name).join(', '),
      tags: tags.map(&:name).join(', '),
      notes:,
      updated_at:
    }
  end
end
