class Keyword < ApplicationRecord
  belongs_to :citation, optional: true
end
