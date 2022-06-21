class AbstractScreeningsCitationsProject < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :citations_project
end
