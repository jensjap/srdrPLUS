class CitationsProject < ApplicationRecord
  belongs_to :citation
  belongs_to :project
  has_many :labels
  has_many :notes as: :notable
  has_many :tags as: :taggable
  has_one :prediction
  has_one :priority
end
