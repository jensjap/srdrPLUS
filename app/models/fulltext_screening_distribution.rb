class FulltextScreeningDistribution < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :user
  belongs_to :citations_project
end
