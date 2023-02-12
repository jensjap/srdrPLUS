# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord
  has_many :abstract_screening_results_tags
  has_many :abstract_screening_results, through: :abstract_screening_results_tags
  has_many :fulltext_screening_results_tags
  has_many :fulltext_screening_results, through: :fulltext_screening_results_tags

  include SharedQueryableMethods
end
