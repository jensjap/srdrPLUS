# == Schema Information
#
# Table name: journals
#
#  id               :integer          not null, primary key
#  citation_id      :integer
#  volume           :string(255)
#  issue            :string(255)
#  name             :string(1000)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  publication_date :string(255)
#

class Journal < ApplicationRecord
  after_commit :reindex_citations_projects

  belongs_to :citation, optional: true
  has_many :citations_projects, through: :citation

  def get_publication_year
    get_year_through_date || get_year_through_date_time || ''
  end

  def reindex_citations_projects
    citations_projects.each(&:reindex)
  end

  private

  def get_year_through_date
    publication_date.to_date.strftime('%Y')
  rescue StandardError
    nil
  end

  def get_year_through_date_time
    DateTime.strptime(publication_date, '%Y').strftime('%Y')
  rescue StandardError
    nil
  end
end
