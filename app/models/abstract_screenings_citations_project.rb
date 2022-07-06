# == Schema Information
#
# Table name: abstract_screenings_citations_projects
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  citations_project_id  :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningsCitationsProject < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :citations_project
  has_many :abstract_screening_results, dependent: :destroy, inverse_of: :abstract_screenings_citations_project
  has_one :citation, through: :citations_project
end
