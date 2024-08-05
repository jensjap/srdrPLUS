# == Schema Information
#
# Table name: statusings
#
#  id              :bigint           not null, primary key
#  statusable_type :string(255)
#  statusable_id   :bigint
#  status_id       :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Statusing < ApplicationRecord
  belongs_to :statusable, polymorphic: true
  belongs_to :status, inverse_of: :statusings

  validates :statusable, :status, presence: true

  delegate :project, to: :statusable

  after_save :evaluate_screening_status_citations_project

  def evaluate_screening_status_citations_project
    return unless statusable.instance_of?(ExtractionsExtractionFormsProjectsSection)
    return if statusable.try(:citations_project).try(:marked_for_destruction?)

    statusable.try(:citations_project).try(:evaluate_extraction_qualification_status,
                                           statusable.extraction.consolidated)
    statusable.try(:citations_project).try(:evaluate_screening_status)
  end
end
