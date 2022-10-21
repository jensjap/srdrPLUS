# == Schema Information
#
# Table name: abstract_screening_results
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint
#  user_id               :bigint
#  citation_id           :bigint
#  label                 :integer
#  notes                 :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningResult < ApplicationRecord
  searchkick

  belongs_to :abstract_screening
  belongs_to :project_citation
  belongs_to :citation, through: :citation
  belongs_to :user

  has_many :abstract_screening_results_reasons
  has_many :reasons, through: :abstract_screening_results_reasons
  has_many :abstract_screening_results_tags
  has_many :tags, through: :abstract_screening_results_tags
  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :abstract_screening_result

  delegate :project, to: :abstract_screening

  def search_data
    {
      id:,
      abstract_screening_id:,
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
