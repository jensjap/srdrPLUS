class CitationsTask < ApplicationRecord
  belongs_to :citation
  belongs_to :task
end
