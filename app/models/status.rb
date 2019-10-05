class Status < ApplicationRecord
  has_many :statusings, inverse_of: :status
end
