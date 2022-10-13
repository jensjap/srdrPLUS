class AbstractScreeningsReasonsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :reason
  belongs_to :user
end
