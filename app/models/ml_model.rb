class MlModel < ApplicationRecord
  belongs_to :project
  validates :timestamp, presence: true
end
