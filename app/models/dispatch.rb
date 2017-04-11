class Dispatch < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :dispatchable, polymorphic: true
  belongs_to :user, inverse_of: :dispatches
end
