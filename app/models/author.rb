class Author < ApplicationRecord
  belongs_to :citation, optional: true
end