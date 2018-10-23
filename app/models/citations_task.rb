class CitationsTask < ApplicationRecord
  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :citation
  belongs_to :task
end
