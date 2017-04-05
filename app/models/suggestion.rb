class Suggestion < ApplicationRecord
  acts_as_paranoid

  belongs_to :suggestable, polymorphic: true
  belongs_to :user, inverse_of: :suggestions
end
