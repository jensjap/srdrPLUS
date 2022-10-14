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
