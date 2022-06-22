class AbstractScreeningsReason < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :reason
end
