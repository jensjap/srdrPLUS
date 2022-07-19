# == Schema Information
#
# Table name: fulltext_screenings_citations_projects
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  citations_project_id  :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FulltextScreeningsCitationsProject < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :citations_project
  has_many :fulltext_screening_results, dependent: :destroy, inverse_of: :fulltext_screenings_citations_project
  has_one :citation, through: :citations_project
end
