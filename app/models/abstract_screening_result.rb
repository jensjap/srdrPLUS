# == Schema Information
#
# Table name: abstract_screening_results
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint
#  user_id               :bigint
#  citations_project_id  :bigint
#  label                 :integer
#  notes                 :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningResult < ApplicationRecord
  searchkick

  belongs_to :abstract_screening
  belongs_to :citations_project
  belongs_to :user

  has_many :abstract_screening_results_reasons
  has_many :reasons, through: :abstract_screening_results_reasons
  has_many :abstract_screening_results_tags
  has_many :tags, through: :abstract_screening_results_tags
  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :abstract_screening_result

  delegate :project, to: :abstract_screening
  delegate :citation, to: :citations_project

  after_save :evaluate_screening_qualifications

  def evaluate_screening_qualifications
    return if !saved_change_to_attribute('label') ||
              citations_project
              .screening_qualifications
              .where.not(user: nil)
              .where("qualification_type LIKE 'as-%'")
              .present? ||
              !citations_project_sufficiently_labeled?

    case label
    when 1
      citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::AS_REJECTED).destroy_all
      citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::AS_ACCEPTED)
    when -1
      citations_project.screening_qualifications.where(qualification_type: ScreeningQualification::AS_ACCEPTED).destroy_all
      citations_project.screening_qualifications.find_or_create_by!(qualification_type: ScreeningQualification::AS_REJECTED)
    end
    citations_project.evaluate_screening_status
  end

  def citations_project_sufficiently_labeled?
    return true if abstract_screening.single_screening?

    if abstract_screening.exclusive_users
      relevant_asrs = AbstractScreeningResult.where(abstract_screening:, citations_project:, user: users)
      required_asrs_pilot_count = abstract_screening.abstract_screenings_users.count
    else
      relevant_asrs = AbstractScreeningResult.where(abstract_screening:, citations_project:)
      required_asrs_pilot_count = abstract_screening.project.projects_users.count
    end
    return false unless relevant_asrs.all? { |asr| asr.label == 1 } || relevant_asrs.all? { |asr| asr.label == -1 }

    if abstract_screening.double_screening? && relevant_asrs.count == 2
      true
    elsif abstract_screening.all_screenings? && relevant_asrs.count == required_asrs_pilot_count
      true
    else
      false
    end
  end

  def search_data
    {
      id:,
      abstract_screening_id:,
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
