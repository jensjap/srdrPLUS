class Dependency < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :dependable,      polymorphic: true
  belongs_to :prerequisitable, polymorphic: true
end
