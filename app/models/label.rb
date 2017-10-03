class Label < ApplicationRecord
  belongs_to :citations_project
  belongs_to :user

  has_many :notes, as: :notable
  has_many :tags, as: :taggable

  validates :value, presence: true
end
