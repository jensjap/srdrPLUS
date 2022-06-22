class AbstractScreeningResultsReason < ApplicationRecord
  belongs_to :abstract_screening_result
  belongs_to :reason
end
