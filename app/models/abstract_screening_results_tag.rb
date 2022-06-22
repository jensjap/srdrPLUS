class AbstractScreeningResultsTag < ApplicationRecord
  belongs_to :abstract_screening_result
  belongs_to :tag
end
