# == Schema Information
#
# Table name: word_weights
#
#  id         :bigint           not null, primary key
#  weight     :integer          not null
#  word       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#
class WordWeight < ApplicationRecord
  belongs_to :user, optional: true # TO DO: DELETE AFTER MIGRATING
  belongs_to :abstract_screening, optional: true # TO DO: DELETE AFTER MIGRATING

  belongs_to :project

  def self.word_weights_object(project)
    word_weights = WordWeight.where(project:)
    word_weights.each_with_object({}) do |ww, hash|
      hash[ww.word] = { weight: ww.weight, id: ww.id }
      hash
    end
  end
end
