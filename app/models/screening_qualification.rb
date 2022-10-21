class ScreeningQualification < ApplicationRecord
  belongs_to :citations_project
  belongs_to :user
end
