class Statusing < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :statusable, polymorphic: true
  belongs_to :status, inverse_of: :statusings

  validates :statusable, :status, presence: true
end
