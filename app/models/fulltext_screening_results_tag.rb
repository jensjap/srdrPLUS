# == Schema Information
#
# Table name: fulltext_screening_results_tags
#
#  id                           :bigint           not null, primary key
#  fulltext_screening_result_id :bigint           not null
#  tag_id                       :bigint           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class FulltextScreeningResultsTag < ApplicationRecord
  belongs_to :fulltext_screening_result
  belongs_to :tag

  after_commit :reindex_fsr

  private

  def reindex_fsr
    fulltext_screening_result.try(:reindex)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
