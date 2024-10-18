class WordGroup < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_many :word_weights, dependent: :destroy

  def self.word_weights_object(user, project)
    word_groups = WordGroup.where(user:, project:)
    word_groups.each_with_object({}) do |wg, hash|
      hash[wg.id] ||= [{color: wg.color, group_name: wg.name, group_id: wg.id, case_sensitive: wg.case_sensitive, word: nil, id: nil}]

      wg.word_weights.each do |ww|
        hash[wg.id] << {
          word: ww.word,
          color: wg.color,
          id: ww.id,
          group_name: wg.name,
          group_id: wg.id,
          case_sensitive: ww.case_sensitive,
          full_match: ww.full_match,
        } unless ww.nil?
      end

      hash[wg.id].shift if hash[wg.id].size > 1
    end
  end
end
