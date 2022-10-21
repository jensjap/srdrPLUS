# == Schema Information
#
# Table name: fulltext_screening_results
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint
#  user_id               :bigint
#  citation_id           :bigint
#  label                 :integer
#  notes                 :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FulltextScreeningResult < ApplicationRecord
  searchkick

  belongs_to :fulltext_screening
  belongs_to :citations_project
  belongs_to :user

  has_many :fulltext_screening_results_reasons
  has_many :reasons, through: :fulltext_screening_results_reasons
  has_many :fulltext_screening_results_tags
  has_many :tags, through: :fulltext_screening_results_tags
  has_many :sf_fulltext_records, dependent: :destroy, inverse_of: :fulltext_screening_result

  delegate :project, to: :fulltext_screening
  delegate :citation, to: :citations_project

  def search_data
    {
      id:,
      fulltext_screening_id:,
      accession_number_alts: citation.accession_number_alts,
      author_map_string: citation.author_map_string,
      name: citation.name,
      year: citation.year,
      user: user.handle,
      user_id:,
      label:,
      reasons: reasons.map(&:name).join(', '),
      tags: tags.map(&:name).join(', '),
      notes:,
      updated_at:
    }
  end

  def readable_label
    case label
    when -1
      'No'
    when 0
      'Maybe'
    when 1
      'Yes'
    end
  end
end
