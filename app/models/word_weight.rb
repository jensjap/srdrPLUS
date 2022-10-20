# == Schema Information
#
# Table name: word_weights
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  abstract_screening_id :bigint
#  weight                :integer          not null
#  word                  :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class WordWeight < ApplicationRecord
  belongs_to :user
  belongs_to :abstract_screening

  def self.word_weights_object(user, abstract_screening)
    word_weights = WordWeight.where(user:, abstract_screening:)
    word_weights.each_with_object({}) do |ww, hash|
      hash[ww.word] = { weight: ww.weight, id: ww.id }
      hash
    end
  end
end
