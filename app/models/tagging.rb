class Tagging < ApplicationRecord
  belongs_to :user
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
