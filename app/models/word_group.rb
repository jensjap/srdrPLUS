class WordGroup < ApplicationRecord
  belongs_to :project

  has_many :word_weights, dependent: :destroy

  def self.import_from_word_weights
    weight_map = {
      2 => { name: "default 2", color: "#3b82f6" },
      1 => { name: "default 1", color: "#22c55e" },
      -1 => { name: "default -1", color: "#a855f7" },
      -2 => { name: "default -2", color: "#ef4444" },
    }

    WordWeight.all.each do |ww|
      ww.word_group_id = nil
      next if ww.abstract_screening.nil?

      if weight_map.has_key?(ww.weight)
        name = weight_map[ww.weight][:name]
        color = weight_map[ww.weight][:color]

        word_group = WordGroup.find_or_create_by(name: name, color: color, project_id: ww.abstract_screening.project_id)

        ww.update(word_group_id: word_group.id)
      end
    end
  end

  def self.word_weights_object(project)
    word_groups = WordGroup.where(project: project)
    word_groups.each_with_object({}) do |wg, hash|
      hash[wg.id] ||= [{color: wg.color, group_name: wg.name, group_id: wg.id, word: nil, id: nil}]

      wg.word_weights.each do |ww|
        hash[wg.id] << {
          word: ww.word,
          color: wg.color,
          id: ww.id,
          group_name: wg.name,
          group_id: wg.id
        } unless ww.nil?
      end

      hash[wg.id].shift if hash[wg.id].size > 1
    end
  end
end
