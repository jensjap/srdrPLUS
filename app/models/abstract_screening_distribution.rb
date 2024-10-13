class AbstractScreeningDistribution < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :user
  belongs_to :citations_project
end
