class AbstractScreeningsTagsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :tag
  belongs_to :user
end
