class DegreesProfile < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :degree
  belongs_to :profile

  validates :degree_id, :profile_id, presence: true

  accepts_nested_attributes_for :degree, :reject_if => :all_blank
end

