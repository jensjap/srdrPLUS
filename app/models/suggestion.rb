class Suggestion < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :suggestable, polymorphic: true
  belongs_to :user, inverse_of: :suggestions
end
