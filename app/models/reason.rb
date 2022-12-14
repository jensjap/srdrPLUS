# == Schema Information
#
# Table name: reasons
#
#  id            :integer          not null, primary key
#  name          :string(1000)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  label_type_id :integer
#

class Reason < ApplicationRecord
  has_many :abstract_screening_results_reasons
  has_many :abstract_screening_results, through: :abstract_screening_results_reasons
  has_many :fulltext_screening_results_reasons
  has_many :fulltext_screening_results, through: :fulltext_screening_results_reasons

  include SharedQueryableMethods
end
