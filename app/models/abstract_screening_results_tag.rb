# == Schema Information
#
# Table name: abstract_screening_results_tags
#
#  id                           :bigint           not null, primary key
#  abstract_screening_result_id :bigint           not null
#  tag_id                       :bigint           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class AbstractScreeningResultsTag < ApplicationRecord
  belongs_to :abstract_screening_result
  belongs_to :tag

  after_commit :reindex_asr

  private

  def reindex_asr
    abstract_screening_result.try(:reindex)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
