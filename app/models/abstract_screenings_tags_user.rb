class AbstractScreeningsTagsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(abstract_screening, user)
    astus = AbstractScreeningsTagsUser.where(abstract_screening:, user:).includes(:tag)
    astus.each_with_object({}) do |astu, hash|
      hash[astu.tag.name] = false
      hash
    end
  end
end
