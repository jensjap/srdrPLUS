# == Schema Information
#
# Table name: citations_projects_fulltext_screenings
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  citations_project_id  :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class CitationsProjectsFulltextScreening < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :citations_project
  has_many :fulltext_screening_results, dependent: :destroy, inverse_of: :citations_projects_fulltext_screening
  has_one :citation, through: :citations_project
end
