class Label < ApplicationRecord
  belongs_to :citations_project
  belongs_to :user

  has_many :notes, as: :notable
  has_many :tags, as: :taggable

  has_one :citation, through: :citations_project
  has_one :project, through: :citations_project

  validates :value, presence: true
end
