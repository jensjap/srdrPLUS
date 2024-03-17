class WordGroup < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :user

  has_many :word_weights

  def self.import_from_word_weights
    weight_map = {
      2 => { name: "default 2", color: "blue-500" },
      1 => { name: "default 1", color: "green-500" },
      -1 => { name: "default -1", color: "purple-500" },
      -2 => { name: "default -2", color: "red-500" },
    }

    WordWeight.all.each do |ww|
      ww.word_group_id = nil

      if weight_map.has_key?(ww.weight)
        name = weight_map[ww.weight][:name]
        color = weight_map[ww.weight][:color]

        word_group = WordGroup.find_or_create_by(name: name, color: color, abstract_screening_id: ww.abstract_screening_id, user_id: ww.user_id)

        ww.update(word_group_id: word_group.id)
      end
    end
  end

  def self.word_weights_object(user, abstract_screening)
    word_groups = WordGroup.where(user:, abstract_screening:)
    word_groups.each_with_object({}) do |wg, hash|
      wg.word_weights.each do |ww|
        hash[ww.word] = {
          bg_color: "bg-".concat(wg.color),
          text_color: "text-".concat(wg.color),
          id: ww.id,
          group_name: wg.name,
          group_id: wg.id
        }
      end
      hash
    end
  end
end
