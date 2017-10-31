class DegreesProfile < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :degree,  inverse_of: :degrees_profiles
  belongs_to :profile, inverse_of: :degrees_profiles

  validates :degree_id, :profile_id, presence: true

  accepts_nested_attributes_for :degree, :reject_if => :all_blank
end

