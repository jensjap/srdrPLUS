class CitationsProject < ApplicationRecord
  belongs_to :citation
  belongs_to :project

  has_one :prediction, dependent: :destroy
  has_one :priority, dependent: :destroy

  has_many :labels, dependent: :destroy
  has_many :notes as: :notable, dependent: :destroy
  has_many :tags as: :taggable, dependent: :destroy
end
