class Publishing < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :publishable, polymorphic: true
  belongs_to :user, inverse_of: :publishings

  has_one :approval, as: :approvable, dependent: :destroy
end
