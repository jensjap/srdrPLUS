class Journal < ApplicationRecord
  belongs_to :citation, optional: true
end
